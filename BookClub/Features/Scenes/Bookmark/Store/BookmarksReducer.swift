//
//  BookmarksReducer.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Alamofire
import Foundation

private enum CancellationID {
    static let bookmarks = "BookmarksOnAppear"
}

@MainActor
func bookmarksReducer(
    state: inout BookmarksState,
    action: BookmarksAction,
    env: BookmarksEnvironment
) -> Effect<BookmarksAction> {
    switch action {

    case .onAppear:
        guard !state.didLoadOnAppear else { return .none }
        state.didLoadOnAppear = true

        // сразу запускаем все три параллельно
        return .batch([
            loadLocalQuotesEffect(env: env, bookId: state.currentReadingId),
            loadReadingProgressEffect(
                env: env,
                bookId: state.currentReadingDocumentId
            ),
            loadFavoritesEffect(env: env),
        ])
        .cancellable(id: CancellationID.bookmarks)

    case .onDisappear:
        return .cancel(id: CancellationID.bookmarks)

    // MARK: — Quotes

    case .loadLocalQuotes:
        state.quotes = .loading
        let bookId = state.currentReadingId
        return .task(id: CancellationID.bookmarks) {
            do {
                let entities = try await env.quoteStorage.fetchQuotes(
                    forBookId: bookId
                )
                let items = entities.map {
                    QuoteItem(
                        id: $0.id,
                        documentId: $0.documentId,
                        text: $0.text,
                        bookId: $0.bookId
                    )
                }
                return .localQuotesLoaded(.success(items))
            } catch {
                return .localQuotesLoaded(
                    .failure(
                        error as? NetworkError ?? .otherURL(URLError(.unknown))
                    )
                )
            }
        }

    case let .localQuotesLoaded(.success(items)):
        state.quotes = .loaded(items)

        let metadataEffects = items.map { item in
            Effect<BookmarksAction>.task(id: CancellationID.bookmarks) {
                if let book = try? await env.bookStorage.fetch(
                    byDocumentId: item.documentId
                ) {
                    return .bookMetadataLoaded(
                        documentId: item.documentId,
                        book: book
                    )
                } else {
                    return .noop
                }
            }
        }

        return .batch(metadataEffects)

    case let .deleteQuote(id):
        return .task(id: CancellationID.bookmarks) {
            try? await env.quoteStorage.deleteQuote(id: id)
            return .loadLocalQuotes
        }

    case let .bookMetadataLoaded(documentId, book):
        state.booksByDocumentId[documentId] = book
        return .none

    case let .localQuotesLoaded(.failure(err)):
        state.quotes = .failure(err.localizedKey)
        state.errorMessage = err.localizedKey
        return .none

    // MARK: — Progress

    case .loadReadingProgress:
        state.readingProgress = .loading
        return loadReadingProgressEffect(
            env: env,
            bookId: state.currentReadingDocumentId
        )

    case let .readingProgressLoaded(result):
        switch result {
        case .success(let dict): state.readingProgress = .loaded(dict)
        case .failure(let err):
            state.readingProgress = .failure(err.localizedKey)
            state.errorMessage = err.localizedKey
        }
        return .none

    // MARK: — Favorites

    case .loadFavorites:
        state.favorites = .loading
        return loadFavoritesEffect(env: env)

    case let .favoritesLoaded(result):
        switch result {
        case .success(let set): state.favorites = .loaded(set)
        case .failure(let err):
            state.favorites = .failure(err.localizedKey)
            state.errorMessage = err.localizedKey
        }
        return .none

    // MARK: — Navigation

    case let .quoteTapped(id):
        state.selectedDocumentId = id
        return .none

    case let .continueReading(id):
        state.selectedDocumentId = id
        return .none

    case .clearError:
        state.errorMessage = nil
        return .none

    case .noop:
        return .none

    }
}
// MARK: — Effects helpers

private func loadLocalQuotesEffect(
    env: BookmarksEnvironment,
    bookId: Int64?
) -> Effect<BookmarksAction> {
    .task(id: CancellationID.bookmarks) {
        do {
            let entities = try await env.quoteStorage.fetchQuotes(
                forBookId: bookId
            )
            let items = entities.map { entity in
                QuoteItem(
                    id: entity.id,
                    documentId: entity.documentId,
                    text: entity.text,
                    bookId: entity.bookId
                )
            }
            return .localQuotesLoaded(.success(items))
        } catch {
            let net = (error as? NetworkError) ?? .otherURL(URLError(.unknown))
            return .localQuotesLoaded(.failure(net))
        }
    }
}

private func loadReadingProgressEffect(
    env: BookmarksEnvironment,
    bookId: String?
) -> Effect<BookmarksAction> {
    .task(id: CancellationID.bookmarks) {
        guard let doc = bookId else {
            return .readingProgressLoaded(.success([:]))
        }
        // сначала CoreData
        do {
            let progress = try await env.chapterStorage.computeProgress(
                forBook: doc
            )
            return .readingProgressLoaded(.success([doc: progress]))
        } catch {
            // fallback to network
            do {
                let wrapper: StrapiResponse<[ReadingProgressNetworkItem]> =
                    try await env.networkClient.request(
                        ReadSessionConfig.getProgresses,
                        decoder: JSONDecoder()
                    )
                let dict = Dictionary(
                    uniqueKeysWithValues: wrapper.data.map {
                        ($0.documentId, $0.progress)
                    }
                )
                return .readingProgressLoaded(.success(dict))
            } catch let net as NetworkError {
                return .readingProgressLoaded(.failure(net))
            } catch {
                let afErr = AFError.sessionInvalidated(error: error)
                return .readingProgressLoaded(.failure(.afError(afErr)))
            }
        }
    }
}

private func loadFavoritesEffect(
    env: BookmarksEnvironment
) -> Effect<BookmarksAction> {
    .task(id: CancellationID.bookmarks) {
        // локально
        do {
            let books = try await env.bookStorage.fetch(isNew: nil)
            let favs = Set(books.filter { $0.isFavorite ?? false }.map(\.id))
            return .favoritesLoaded(.success(favs))
        } catch {
            // fallback to network
            do {
                let wrapper: StrapiResponse<[FavoriteNetworkItem]> =
                    try await env.networkClient.request(
                        BookmarksConfig.favorites,
                        decoder: JSONDecoder()
                    )
                let ids = Set(wrapper.data.map(\.bookId))
                return .favoritesLoaded(.success(ids))
            } catch let net as NetworkError {
                return .favoritesLoaded(.failure(net))
            } catch {
                let afErr = AFError.sessionInvalidated(error: error)
                return .favoritesLoaded(.failure(.afError(afErr)))
            }
        }
    }
}
