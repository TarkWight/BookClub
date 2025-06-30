//
//  SearchReducer.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

private enum SearchCancellationID {
    static let onAppear = "SearchOnAppear"
    static let performReq = "SearchPerformRequest"
    static let metadataReq = "SearchMetadataRequest"
}

@MainActor
func searchReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {

    case .onAppear:
        return .batch([
            .task(id: SearchCancellationID.onAppear) { .fetchRecentSearches },
            .task(id: SearchCancellationID.onAppear) { .fetchLocalGenres },
            .task(id: SearchCancellationID.onAppear) { .fetchLocalAuthors },
        ])
    case .onDisappear:
        return .batch([
            .cancel(id: SearchCancellationID.onAppear),
            .cancel(id: SearchCancellationID.performReq),
            .cancel(id: SearchCancellationID.metadataReq),
        ])

    case .fetchRecentSearches,
        .addRecentSearch,
        .recentSearchesLoaded,
        .removeRecentSearch:
        return recentSearchesReducer(
            state: &state,
            action: action,
            env: env
        )

    case .fetchLocalGenres,
        .localGenresLoaded,
        .fetchLocalAuthors,
        .localAuthorsLoaded:
        return localMetadataReducer(
            state: &state,
            action: action,
            env: env
        )

    case .didChangeSearchText,
        .didClearSearch:
        return searchInputReducer(state: &state, action: action)

    case .didSelectRecentSearch,
        .didSelectGenre,
        .didSelectAuthor,
        .didTapSearch,
        .fetchBooksByText,
        .fetchBooksByGenre,
        .fetchBooksByAuthor:
        return searchResultsTriggerReducer(
            state: &state,
            action: action,
            env: env
        )

    case .booksByTextLoaded,
        .booksByGenreLoaded,
        .booksByAuthorLoaded:
        let effect = searchResultsResponseReducer(
            state: &state,
            action: action
        )
        return .batch([effect, .cancel(id: SearchCancellationID.performReq)])

    case .fetchRemoteGenres,
        .remoteGenresLoaded,
        .fetchRemoteAuthors,
        .remoteAuthorsLoaded:
        return remoteMetadataReducer(
            state: &state,
            action: action,
            env: env
        )

    case .didSelectBook(let documentId):
        state.selectedBookID = documentId
        return .none

    case .dismissError:
        state.lastErrorMessage = nil
        return .none
    }
}

private func recentSearchesReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    case .fetchRecentSearches:
        return .task(id: SearchCancellationID.onAppear) {
            do {
                let recents = try await env.recentSearchService.load()
                return .recentSearchesLoaded(recents)
            } catch {
                return .recentSearchesLoaded([])
            }
        }

    case .addRecentSearch(let recent):
        return .merge(
            .fireAndForget(id: SearchCancellationID.onAppear) {
                try? await env.recentSearchService.add(recent)
            },
            .task(id: SearchCancellationID.onAppear) { .fetchRecentSearches }
        )

    case .recentSearchesLoaded(let recents):
        state.recentSearches = recents
        return .none

    case .removeRecentSearch(let query):
        return .task(id: SearchCancellationID.onAppear) {
            try? await env.recentSearchService.remove(query)
            let recents = (try? await env.recentSearchService.load()) ?? []
            return .recentSearchesLoaded(recents)
        }

    default:
        return .none
    }
}

private func localMetadataReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    case .fetchLocalGenres:
        state.genres = .loading
        return .task(id: SearchCancellationID.onAppear) {
            do {
                let items = try await env.genreStorage.fetchAll()
                return .localGenresLoaded(items)
            } catch {
                return .localGenresLoaded([])
            }
        }

    case .localGenresLoaded(let items):
        state.genres = .loaded(items)
        return .none

    case .fetchLocalAuthors:
        state.authors = .loading
        return .task(id: SearchCancellationID.onAppear) {
            do {
                let items = try await env.authorStorage.fetchAll()
                return .localAuthorsLoaded(items)
            } catch {
                return .localAuthorsLoaded([])
            }
        }

    case .localAuthorsLoaded(let items):
        state.authors = .loaded(items)
        return .none

    default:
        return .none
    }
}

private func searchInputReducer(
    state: inout SearchState,
    action: SearchAction
) -> Effect<SearchAction> {
    switch action {
    case .didChangeSearchText(let text):
        if text.isEmpty {
            state.filter = nil
            state.searchResults = .idle
        } else {
            state.filter = .text(text)
        }
        return .none

    case .didClearSearch:
        state.filter = nil
        state.searchResults = .idle
        return .none

    default:
        return .none
    }
}

private func searchResultsTriggerReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    state.searchResults = .loading

    switch action {
    case .didSelectRecentSearch(let query):
        state.filter = .text(query)
        return performSearch(
            config: SearchConfig.booksByTitle(query: query),
            success: SearchAction.booksByTextLoaded,
            env: env
        )

    case .didSelectGenre(let genre):
        state.filter = .genre(genre)
        return performSearch(
            config: SearchConfig.booksByGenre(id: Int(genre.id)),
            success: SearchAction.booksByGenreLoaded,
            env: env
        )

    case .didSelectAuthor(let author):
        state.filter = .author(author)
        return performSearch(
            config: SearchConfig.booksByAuthor(id: Int(author.id)),
            success: SearchAction.booksByAuthorLoaded,
            env: env
        )

    case .didTapSearch:
        guard case let .text(query) = state.filter else {
            return .none
        }
        return performSearch(
            config: SearchConfig.booksByTitle(query: query),
            success: SearchAction.booksByTextLoaded,
            env: env
        )

    case .fetchBooksByText(let query):
        return performSearch(
            config: SearchConfig.booksByTitle(query: query),
            success: SearchAction.booksByTextLoaded,
            env: env
        )

    case .fetchBooksByGenre(let genre):
        return performSearch(
            config: SearchConfig.booksByGenre(id: Int(genre.id)),
            success: SearchAction.booksByGenreLoaded,
            env: env
        )

    case .fetchBooksByAuthor(let author):
        return performSearch(
            config: SearchConfig.booksByAuthor(id: Int(author.id)),
            success: SearchAction.booksByAuthorLoaded,
            env: env
        )

    default:
        return .none
    }
}

private func performSearch(
    config: SearchConfig,
    success: @escaping (Result<[BookDetailsItem], NetworkError>) ->
        SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    .task(id: SearchCancellationID.performReq) {
        do {
            let wrapper: StrapiResponse<[BookDetailsItem]> =
                try await env.networkClient.request(
                    config,
                    decoder: JSONDecoder()
                )
            return success(.success(wrapper.data))
        } catch let netErr as NetworkError {
            return success(.failure(netErr))
        } catch {
            let urlErr = (error as? URLError) ?? URLError(.unknown)
            return success(.failure(.otherURL(urlErr)))
        }
    }
}

@MainActor
private func searchResultsResponseReducer(
    state: inout SearchState,
    action: SearchAction
) -> Effect<SearchAction> {
    switch action {
    case .booksByTextLoaded(let result),
        .booksByGenreLoaded(let result),
        .booksByAuthorLoaded(let result):
        switch result {
        case .success(let items):
            state.searchResults = .loaded(items)
        case .failure(let err):
            state.searchResults = .failure(err.localizedKey)
            state.lastErrorMessage = err.localizedKey
        }
        return .none

    default:
        return .none
    }
}

@MainActor
private func remoteMetadataReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    case .fetchRemoteGenres:
        state.genres = .loading
        return .task(id: SearchCancellationID.metadataReq) {
            do {
                let wrapper: StrapiResponse<[GenreItem]> =
                    try await env.networkClient.request(
                        SearchConfig.genres,
                        decoder: JSONDecoder()
                    )
                return .remoteGenresLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .remoteGenresLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .remoteGenresLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .remoteGenresLoaded(let result):
        switch result {
        case .success(let items):
            state.genres = .loaded(items)
            return .batch([
                .cancel(id: SearchCancellationID.metadataReq),
                .fireAndForget(id: SearchCancellationID.metadataReq) {
                    try? await env.genreStorage.save(items)
                },
            ])
        case .failure(let err):
            state.genres = .failure(err.localizedKey)
            return .none
        }

    case .fetchRemoteAuthors:
        state.authors = .loading
        return .task(id: SearchCancellationID.metadataReq) {
            do {
                let wrapper: StrapiResponse<[AuthorItem]> =
                    try await env.networkClient.request(
                        SearchConfig.authors,
                        decoder: JSONDecoder()
                    )
                return .remoteAuthorsLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .remoteAuthorsLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .remoteAuthorsLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .remoteAuthorsLoaded(let result):
        switch result {
        case .success(let items):
            state.authors = .loaded(items)
            return .batch([
                .cancel(id: SearchCancellationID.metadataReq),
                .fireAndForget(id: SearchCancellationID.metadataReq) {
                    try? await env.authorStorage.save(items)
                },
            ])
        case .failure(let err):
            state.authors = .failure(err.localizedKey)
            return .none
        }

    default:
        return .none
    }
}
