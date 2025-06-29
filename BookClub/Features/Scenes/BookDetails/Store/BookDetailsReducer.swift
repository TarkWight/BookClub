//
//  BookDetailsReducer.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Alamofire
import Foundation

@MainActor
func bookDetailsReducer(
    state: inout BookDetailsState,
    action: BookDetailsAction,
    env: BookDetailsEnvironment
) -> Effect<BookDetailsAction> {
    switch action {

    case let .configure(
        bookId,
        documentId,
        title,
        author,
        description,
        coverURL
    ):
        state.bookId = bookId
        state.bookDocumentId = documentId
        state.title = title
        state.author = author
        state.description = description
        state.coverURL = coverURL
        print(
            "[BookDetailsReducer].configure | bookId = \(bookId), documentId = \(documentId)"
        )
        return .none

    case .onAppear:
        let documentId = state.bookDocumentId
        let numericBookId = state.bookId

        return .batch([
            .task {
                do {
                    let chapterSummaries = try await env.chapterStorage
                        .fetchChapterSummaries(forDocumentId: documentId)
                    return .chaptersLoaded(.success(chapterSummaries))
                } catch let err as NetworkError {
                    return .chaptersLoaded(.failure(err))
                } catch {
                    let wrapper = AFError.sessionInvalidated(error: error)
                    return .chaptersLoaded(.failure(.afError(wrapper)))
                }
            },

            .task {
                do {
                    let progressValue = try await env.chapterStorage
                        .computeProgress(forBook: documentId)
                    return .progressLoaded(.success(progressValue))
                } catch let err as NetworkError {
                    return .progressLoaded(.failure(err))
                } catch {
                    let wrapper = AFError.sessionInvalidated(error: error)
                    return .progressLoaded(.failure(.afError(wrapper)))
                }
            },

            .task {
                do {
                    let response: FavoritesListResponse =
                        try await env.networkClient
                        .request(
                            BookDetailsConfig.getFavorites,
                            decoder: JSONDecoder()
                        )
                    let matching = response.data.first {
                        $0.bookId == numericBookId
                    }
                    let status = FavoriteStatus(
                        isFavorite: matching != nil,
                        favoriteId: matching.map { String($0.id) }
                    )
                    return .favoriteStatusLoaded(.success(status))
                } catch let err as NetworkError {
                    return .favoriteStatusLoaded(.failure(err))
                } catch {
                    let wrapper = AFError.sessionInvalidated(error: error)
                    return .favoriteStatusLoaded(.failure(.afError(wrapper)))
                }
            },
        ])

    case let .chaptersLoaded(.success(chapters)):
        state.chapters = chapters
        return .none

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
        let willBeFav = !state.isFavorite
        state.isFavorite = willBeFav
        let bookId = state.bookId
        let existingFavId = state.favoriteId

        return .task {
            do {
                if willBeFav {
                    let resp: FavoriteCreateResponse =
                        try await env.networkClient
                        .request(
                            BookDetailsConfig.addToFavorites(bookId: bookId),
                            decoder: JSONDecoder()
                        )
                    return .favoriteToggled(.success(String(resp.data.id)))
                } else if let fid = existingFavId {
                    try await env.networkClient
                        .request(
                            BookDetailsConfig.removeFromFavorites(
                                favoriteId: fid
                            )
                        )
                    return .favoriteToggled(.success(nil))
                } else {
                    return .favoriteToggled(.success(nil))
                }
            } catch let err as NetworkError {
                return .favoriteToggled(.failure(err))
            } catch {
                let wrapper = AFError.sessionInvalidated(error: error)
                return .favoriteToggled(.failure(.afError(wrapper)))
            }
        }

    case let .favoriteToggled(.success(newId)):
        state.favoriteId = newId
        return .none

    case .favoriteToggled(.failure):
        state.isFavorite.toggle()
        return .none

    case .downloadBookTapped:
        state.bookDownload = .loading
        let bookId = state.bookId
        let documentId = state.bookDocumentId

        return .task {
            do {
                let wrapper: StrapiResponse<[ChapterNetworkItem]> =
                    try await env.networkClient.request(
                        BookDetailsConfig.getBookChapters(bookId: bookId),
                        decoder: JSONDecoder()
                    )
                let chapterDTOs = wrapper.data.map { net in
                    ChapterDTO(
                        id: net.id,
                        documentId: net.documentId,
                        order: net.order,
                        title: net.title,
                        text: net.text,
                        status: .notStarted
                    )
                }
                try await env.chapterStorage.saveFullChapters(
                    chapterDTOs,
                    forDocumentId: documentId
                )
                return .downloadBookResponse(.success(chapterDTOs))
            } catch let netErr as NetworkError {
                return .downloadBookResponse(.failure(netErr))
            } catch {
                let afErr = AFError.sessionInvalidated(error: error)
                return .downloadBookResponse(.failure(.afError(afErr)))
            }
        }

    case let .downloadBookResponse(.success(chaps)):
        state.bookDownload = .loaded(chaps)
        let docId = state.bookDocumentId
        let firstOrder = chaps.first?.order ?? 1

        return .fireAndForget {
            await env.readingSession.startReading(
                documentId: docId,
                chapterOrder: firstOrder
            )
        }

    case let .downloadBookResponse(.failure(err)):
        state.bookDownload = .failure(err.localizedKey)
        return .none

    case .startReadingTapped:
        switch state.bookDownload {
        case .loaded:
            let nextOrder =
                state.chapters.first { $0.status != .completed }?.order ?? 1
            state.selectedChapterOrder = nextOrder
            let docId = state.bookDocumentId

            return .fireAndForget {
                await env.readingSession.startReading(
                    documentId: docId,
                    chapterOrder: nextOrder
                )
            }
        case .idle, .loading, .failure:
            return bookDetailsReducer(
                state: &state,
                action: .downloadBookTapped,
                env: env
            )
        }

    case let .chapterTapped(order):
        state.selectedChapterOrder = order
        let docId = state.bookDocumentId

        return .fireAndForget {
            await env.readingSession.startReading(
                documentId: docId,
                chapterOrder: order
            )
        }

    case .openChapter:
        state.selectedChapterOrder = nil
        return .none

    case .backButtonTapped:
        //        state.featureDidClose = true
        return .none
    }
}
