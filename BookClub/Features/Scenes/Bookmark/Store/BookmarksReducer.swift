//
//  BookmarksReducer.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Alamofire
import Foundation

private enum CancellationID {
    static let quotes    = "BookmarksQuotes"
    static let progress  = "BookmarksProgress"
    static let favorites = "BookmarksFavorites"
    static let metadata  = "BookmarksMetadata"
    static let delete    = "BookmarksDelete"
}

@MainActor
func bookmarksReducer(
    state: inout BookmarksState,
    action: BookmarksAction,
    env: BookmarksEnvironment
) -> Effect<BookmarksAction> {
    print("[BookmarksReducer] ↓ action:", action)

    switch action {

    case .onAppear:
        guard !state.didLoadOnAppear else { return .none }
        state.didLoadOnAppear = true

        let quotesE = loadLocalQuotesEffect(
            env: env,
            bookId: state.currentReadingId
        )
        .cancellable(id: CancellationID.quotes)

        let progressE = loadReadingProgressEffect(
            env: env,
            bookId: state.currentReadingDocumentId
        )
        .cancellable(id: CancellationID.progress)

        let favsE = loadFavoritesEffect(env: env)
            .cancellable(id: CancellationID.favorites)

        return .batch([quotesE, progressE, favsE])

    case .onDisappear:
        return .batch([
            .cancel(id: CancellationID.quotes),
            .cancel(id: CancellationID.progress),
            .cancel(id: CancellationID.favorites),
            .cancel(id: CancellationID.metadata),
            .cancel(id: CancellationID.delete),
        ])

    case .loadLocalQuotes:
        print("[BookmarksReducer] loadLocalQuotes")
        state.quotes = .loading
        return loadLocalQuotesEffect(env: env, bookId: state.currentReadingId)

    case let .localQuotesLoaded(.success(items)):
        print("[BookmarksReducer] localQuotesLoaded:", items.count, "цитат")
        state.quotes = .loaded(items)

        let metadataEffects = items.map { item in
            Effect<BookmarksAction>.task(id: CancellationID.metadata) {
                print(
                    "[BookmarksReducer] fetch metadata for quote.documentId =",
                    item.documentId
                )
                if let book = try? await env.bookStorage.fetch(
                    byDocumentId: item.documentId
                ) {
                    print(
                        "[BookmarksReducer] bookMetadataLoaded for",
                        item.documentId
                    )
                    return .bookMetadataLoaded(
                        documentId: item.documentId,
                        book: book
                    )
                } else {
                    print(
                        "[BookmarksReducer] book not found locally for",
                        item.documentId
                    )
                    return .noop
                }
            }
        }
        return .batch(metadataEffects)

    case let .localQuotesLoaded(.failure(err)):
        print("[BookmarksReducer] failed to load local quotes:", err)
        state.quotes = .failure(err.localizedKey)
        state.errorMessage = err.localizedKey
        return .none

    case let .deleteQuote(id):
        print("[BookmarksReducer] deleteQuote id =", id)
        return .task(id: CancellationID.delete) {
            try? await env.quoteStorage.deleteQuote(id: id)
            print("[BookmarksReducer] deletion done, перезагружаем цитаты")
            return .loadLocalQuotes
        }

    case let .bookMetadataLoaded(documentId, book):
        print(
            "[BookmarksReducer] bookMetadataLoaded:",
            documentId,
            "→",
            book.title
        )
        state.booksByDocumentId[documentId] = book

        let details = BookDetailsItem(
            id: book.id,
            documentId: book.documentId,
            title: book.title,
            coverURL: book.coverURL,
            isNew: book.isNew,
            illustrationURL: book.illustrationURL,
            isFavorite: book.isFavorite ?? false,
            authorName: book.authorName,
            description: book.description
        )
        state.booksById[book.id] = details
        return .none

    case .loadReadingProgress:
        print("[BookmarksReducer] loadReadingProgress")
        state.readingProgress = .loading
        return loadReadingProgressEffect(
            env: env,
            bookId: state.currentReadingDocumentId
        )

    case let .readingProgressLoaded(.success(dict)):
        print("[BookmarksReducer] readingProgressLoaded:", dict)
        state.readingProgress = .loaded(dict)
        return .none
    case let .readingProgressLoaded(.failure(err)):
        print("[BookmarksReducer] readingProgressLoaded failed:", err)
        state.readingProgress = .failure(err.localizedKey)
        state.errorMessage = err.localizedKey
        return .none

    case .loadFavorites:
        print("[BookmarksReducer] loadFavorites")
        state.favorites = .loading
        return loadFavoritesEffect(env: env)

    case let .favoritesLoaded(.success(set)):
        print("[BookmarksReducer] favoritesLoaded:", set)
        state.favorites = .loaded(set)
        return .none
    case let .favoritesLoaded(.failure(err)):
        print("[BookmarksReducer] favoritesLoaded failed:", err)
        state.favorites = .failure(err.localizedKey)
        state.errorMessage = err.localizedKey
        return .none

    case let .quoteTapped(id):
        print("[BookmarksReducer] quoteTapped →", id)
        state.selectedDocumentId = id
        return .none

    case let .continueReading(id):
        print("[BookmarksReducer] continueReading →", id)
        state.selectedDocumentId = id
        return .none

    case .clearError:
        print("[BookmarksReducer] clearError")
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
    .task(id: CancellationID.quotes) {
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
            if !items.isEmpty {
                print(
                    "[Effect] fetched \(items.count) local quotes, skip network"
                )
                return .localQuotesLoaded(.success(items))
            }

            print("[Effect] no local quotes → fetching from network")
            let wrapper: StrapiResponse<[QuoteNetworkItem]> =
                try await env.networkClient.request(
                    BookmarksConfig.quotes,
                    decoder: JSONDecoder()
                )
            let networkItems = wrapper.data.map { net in
                QuoteItem(
                    id: net.id,
                    documentId: net.documentId,
                    text: net.text,
                    bookId: net.bookId
                )
            }
            try await env.quoteStorage.save(quotes: networkItems)

            print("[Effect] fetched \(networkItems.count) quotes from network")
            return .localQuotesLoaded(.success(networkItems))
        } catch let net as NetworkError {
            print("[Effect] quotes network error:", net)
            return .localQuotesLoaded(.failure(net))
        } catch {
            let wrapped = NetworkError.otherURL(URLError(.unknown))
            print("[Effect] quotes unexpected error:", error)
            return .localQuotesLoaded(.failure(wrapped))
        }
    }
}

private func loadReadingProgressEffect(
    env: BookmarksEnvironment,
    bookId: String?
) -> Effect<BookmarksAction> {
    .task(id: CancellationID.progress) {
        do {
            print("[Effect] fetching reading progress from network")
            let wrapper: StrapiResponse<[ReadingProgressNetworkItem]> =
                try await env.networkClient.request(
                    ReadSessionConfig.getProgresses,
                    decoder: JSONDecoder()
                )

            let items = wrapper.data
            print("[Effect] got \(items.count) progress items from network")

            let allChapters = try await env.chapterStorage.fetchChapters(forDocumentId: "l9n16lz4rky9talx9ckytly7")
            let chapterToBook: [Int64: String] = Dictionary(
                uniqueKeysWithValues: allChapters.map { chapter in
                    (chapter.id, chapter.documentId)
                }
            )

            var progressPerBook: [String: [Double]] = [:]

            for item in items {
                if let bookDocId = chapterToBook[item.chapterId] {
                    progressPerBook[bookDocId, default: []].append(item.value)
                }
            }

            let averaged: [String: Double] = progressPerBook.mapValues { values in
                values.reduce(0, +) / Double(values.count)
            }

            print("[Effect] aggregated reading progress:", averaged)
            return .readingProgressLoaded(.success(averaged))

        } catch let net as NetworkError {
            print("[Effect] progress network error:", net)
            return .readingProgressLoaded(.failure(net))
        } catch {
            let afErr = AFError.sessionInvalidated(error: error)
            print("[Effect] progress unexpected error:", error)
            return .readingProgressLoaded(.failure(.afError(afErr)))
        }
    }
}

private func loadFavoritesEffect(
    env: BookmarksEnvironment
) -> Effect<BookmarksAction> {
    .task(id: CancellationID.favorites) {
        do {
            let books = try await env.bookStorage.fetch(isNew: nil)
            let favs = Set(books.filter { $0.isFavorite ?? false }.map(\.id))
            if !favs.isEmpty {
                print("[Effect] got local favorites:", favs)
                return .favoritesLoaded(.success(favs))
            }

            print("[Effect] no local favorites → fetching from network")
            let wrapper: StrapiResponse<[FavoriteNetworkItem]> =
                try await env.networkClient.request(
                    BookmarksConfig.favorites,
                    decoder: JSONDecoder()
                )
            let ids = Set(wrapper.data.map(\.bookId))
            print("[Effect] fetched favorites from network:", ids)
            return .favoritesLoaded(.success(ids))
        } catch let net as NetworkError {
            print("[Effect] favorites network error:", net)
            return .favoritesLoaded(.failure(net))
        } catch {
            let afErr = AFError.sessionInvalidated(error: error)
            print("[Effect] favorites unexpected error:", error)
            return .favoritesLoaded(.failure(.afError(afErr)))
        }
    }
}
