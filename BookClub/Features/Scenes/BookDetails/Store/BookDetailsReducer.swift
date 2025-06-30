//
//  BookDetailsReducer.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Alamofire
import Foundation

private enum CancellationID {
  static let onAppear = "BookDetailsOnAppear"
}

@MainActor
func bookDetailsReducer(
    state: inout BookDetailsState,
    action: BookDetailsAction,
    env: BookDetailsEnvironment
) -> Effect<BookDetailsAction> {
    switch action {

    case let .configure(payload):
        state.bookId = payload.bookId
        state.bookDocumentId = payload.documentId
        state.title = payload.title
        state.author = payload.author
        state.description = payload.description
        state.coverURL = payload.coverURL
        return .none

    case .onAppear:
        guard !state.didLoadOnAppear else { return .none }
        state.didLoadOnAppear = true
        return onAppearEffects(state: state, env: env)

    case let .chaptersLoaded(.success(chapters)):
        state.chapters = chapters
        let dicumentId = state.bookDocumentId
        return .task(id: CancellationID.onAppear) {
            do {
                let cached = try await env.chapterStorage
                    .isBookCached(documentId: dicumentId)
                return .cacheStatusLoaded(cached)
            } catch {
                return .cacheStatusLoaded(false)
            }
        }

    case .chaptersLoaded(.failure):
        return .none

    case let .progressLoaded(.success(value)):
        state.progress = value
        return .none
    case .progressLoaded(.failure):
        return .none

    case let .favoriteStatusLoaded(.success(status)):
        state.isFavorite = status.isFavorite
        state.favoriteId = status.favoriteId
        return .none

    case .favoriteStatusLoaded(.failure):
        return .none

    case .toggleFavoriteTapped:
        return favoriteToggleEffects(state: &state, env: env)

    case let .favoriteToggled(.success(newId)):
        state.favoriteId = newId
        return .none

    case .favoriteToggled(.failure):
        state.isFavorite.toggle()
        return .none

    case .downloadBookTapped:
        return downloadBookEffects(state: &state, env: env)

    case let .downloadBookResponse(.success(chaps)):
        state.bookDownload = .loaded(chaps)
        return .startReadingAfterDownload(
            chaps: chaps,
            documentId: state.bookDocumentId,
            env: env
        )

    case let .downloadBookResponse(.failure(err)):
        state.bookDownload = .failure(err.localizedKey)
        return .none

    case .startReadingTapped:
        switch state.bookDownload {
        case .loaded:
            let nextOrder =
                state.chapters.first { $0.status != .completed }?.order ?? 1
            state.selectedChapterOrder = nextOrder
            return .startReading(
                order: nextOrder,
                documentId: state.bookDocumentId,
                env: env
            )
        case .idle, .loading, .failure:
            return bookDetailsReducer(
                state: &state,
                action: .downloadBookTapped,
                env: env
            )
        }

    case let .chapterTapped(order):
        state.selectedChapterOrder = order
        return .startReading(
            order: order,
            documentId: state.bookDocumentId,
            env: env
        )

    case .openChapter:
        state.selectedChapterOrder = nil
        return .none

    case .backButtonTapped:
        return .none

    case let .cacheStatusLoaded(cached):
        state.isDownloaded = cached
        if cached {
            let documetId = state.bookDocumentId
            return .task(id: CancellationID.onAppear) {
                do {
                    let fullChapters = try await env.chapterStorage
                        .fetchChapters(forDocumentId: documetId)
                    return .downloadBookResponse(.success(fullChapters))
                } catch let netErr as NetworkError {
                    return .downloadBookResponse(.failure(netErr))
                } catch {
                    let afErr = AFError.sessionInvalidated(error: error)
                    return .downloadBookResponse(.failure(.afError(afErr)))
                }
            }
        }
        return .none

    case .onDisappear:
        return .cancel(id: CancellationID.onAppear)
    }
}

// MARK: — Private helpers

private func onAppearEffects(
    state: BookDetailsState,
    env: BookDetailsEnvironment
) -> Effect<BookDetailsAction> {
    let docId = state.bookDocumentId
    let numId = state.bookId

    let loadChapters: Effect<BookDetailsAction> = .task(
        id: CancellationID.onAppear
      ) {
        do {
            let chaps = try await env.chapterStorage.fetchChapterSummaries(
                forDocumentId: docId
            )
            return .chaptersLoaded(.success(chaps))
        } catch let net as NetworkError {
            return .chaptersLoaded(.failure(net))
        } catch {
            let wrapper = AFError.sessionInvalidated(error: error)
            return .chaptersLoaded(.failure(.afError(wrapper)))
        }
    }

    let loadProgress: Effect<BookDetailsAction> = .task(
        id: CancellationID.onAppear
      ) {
        do {
            let prog = try await env.chapterStorage.computeProgress(
                forBook: docId
            )
            return .progressLoaded(.success(prog))
        } catch let net as NetworkError {
            return .progressLoaded(.failure(net))
        } catch {
            let wrapper = AFError.sessionInvalidated(error: error)
            return .progressLoaded(.failure(.afError(wrapper)))
        }
    }

    let loadFavStatus: Effect<BookDetailsAction> = .task(
    id: CancellationID.onAppear
  ) {
        do {
            let resp: FavoritesListResponse =
                try await env.networkClient.request(
                    BookDetailsConfig.getFavorites,
                    decoder: JSONDecoder()
                )
            let match = resp.data.first { $0.bookId == numId }
            let status = FavoriteStatus(
                isFavorite: match != nil,
                favoriteId: match.map { String($0.id) }
            )
            return .favoriteStatusLoaded(.success(status))
        } catch let net as NetworkError {
            return .favoriteStatusLoaded(.failure(net))
        } catch {
            let wrapper = AFError.sessionInvalidated(error: error)
            return .favoriteStatusLoaded(.failure(.afError(wrapper)))
        }
    }

    let checkBookCache: Effect<BookDetailsAction> = .task(
    id: CancellationID.onAppear
  ) {
        do {
            if try await env.chapterStorage.isBookCached(documentId: docId) {
                let chapters = try await env.chapterStorage.fetchChapters(
                    forDocumentId: docId
                )
                return .downloadBookResponse(.success(chapters))
            } else {
                return .downloadBookResponse(.failure(.notCached))
            }
        } catch let net as NetworkError {
            return .downloadBookResponse(.failure(net))
        } catch {
            let wrapper = AFError.sessionInvalidated(error: error)
            return .downloadBookResponse(.failure(.afError(wrapper)))
        }
    }

    return .batch([loadChapters, loadProgress, loadFavStatus, checkBookCache])
}

private func favoriteToggleEffects(
    state: inout BookDetailsState,
    env: BookDetailsEnvironment
) -> Effect<BookDetailsAction> {
    let willBeFav = !state.isFavorite
    state.isFavorite = willBeFav
    let bookId = state.bookId
    let existing = state.favoriteId

    return .task(id: CancellationID.onAppear) {
        do {
            if willBeFav {
                let resp: FavoriteCreateResponse =
                    try await env.networkClient.request(
                        BookDetailsConfig.addToFavorites(bookId: bookId),
                        decoder: JSONDecoder()
                    )
                return .favoriteToggled(.success(String(resp.data.id)))
            } else if let fid = existing {
                try await env.networkClient.request(
                    BookDetailsConfig.removeFromFavorites(favoriteId: fid)
                )
                return .favoriteToggled(.success(nil))
            } else {
                return .favoriteToggled(.success(nil))
            }
        } catch let net as NetworkError {
            return .favoriteToggled(.failure(net))
        } catch {
            let wrapper = AFError.sessionInvalidated(error: error)
            return .favoriteToggled(.failure(.afError(wrapper)))
        }
    }
}

private func downloadBookEffects(
    state: inout BookDetailsState,
    env: BookDetailsEnvironment
) -> Effect<BookDetailsAction> {
    state.bookDownload = .loading
    let bookId = state.bookId
    let docId = state.bookDocumentId

    return .task(id: CancellationID.onAppear) {
        do {
            if try await env.chapterStorage.isBookCached(documentId: docId) {
                let chapters = try await env.chapterStorage.fetchChapters(
                    forDocumentId: docId
                )
                return .downloadBookResponse(.success(chapters))
            }

            let wrapper: StrapiResponse<[ChapterNetworkItem]> =
                try await env.networkClient.request(
                    BookDetailsConfig.getBookChapters(bookId: bookId),
                    decoder: JSONDecoder()
                )

            let dtos = wrapper.data.map { net in
                ChapterDTO(
                    id: net.id,
                    documentId: net.documentId,
                    order: net.order,
                    title: net.title,
                    text: net.text,
                    status: .notStarted
                )
            }

            do {
                try await env.chapterStorage.saveFullChapters(
                    dtos,
                    forDocumentId: docId
                )
            } catch {
                throw error
            }

            return .downloadBookResponse(.success(dtos))

        } catch let net as NetworkError {
            return .downloadBookResponse(.failure(net))
        } catch {
            let wrapper = AFError.sessionInvalidated(error: error)
            return .downloadBookResponse(.failure(.afError(wrapper)))
        }
    }
}

@MainActor
private func startReadingEffects(
    state: inout BookDetailsState,
    env: BookDetailsEnvironment
) -> Effect<BookDetailsAction> {
    switch state.bookDownload {
    case .loaded:
        let next = state.chapters.first { $0.status != .completed }?.order ?? 1
        state.selectedChapterOrder = next
        return .startReading(
            order: next,
            documentId: state.bookDocumentId,
            env: env
        )
    case .idle, .loading, .failure:
        return bookDetailsReducer(
            state: &state,
            action: .downloadBookTapped,
            env: env
        )
    }
}

extension Effect where Action == BookDetailsAction {
    fileprivate static func startReading(
        order: Int,
        documentId: String,
        env: BookDetailsEnvironment
    ) -> Effect {
        .fireAndForget(id: CancellationID.onAppear) {
            await env.readingSession.startReading(
                documentId: documentId,
                chapterOrder: order
            )
        }
    }

    fileprivate static func startReadingAfterDownload(
        chaps: [ChapterDTO],
        documentId: String,
        env: BookDetailsEnvironment
    ) -> Effect {
        let first = chaps.first?.order ?? 1
        return .fireAndForget(id: CancellationID.onAppear) {
            await env.readingSession.startReading(
                documentId: documentId,
                chapterOrder: first
            )
        }
    }
}
