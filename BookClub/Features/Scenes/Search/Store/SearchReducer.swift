//
//  SearchReducer.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

@MainActor
func searchReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    // MARK: — Lifecycle
    case .onAppear:
        return .merge(
            .task { .fetchRecentSearches },
            .task { .fetchLocalGenres },
            .task { .fetchLocalAuthors }
        )

    // MARK: — Recent Searches
    case .fetchRecentSearches,
        .addRecentSearch,
        .recentSearchesLoaded,
        .removeRecentSearch:
        return recentSearchesReducer(
            state: &state,
            action: action,
            env: env
        )

    // MARK: — Local DB (genres & authors)
    case .fetchLocalGenres,
        .localGenresLoaded,
        .fetchLocalAuthors,
        .localAuthorsLoaded:
        return localMetadataReducer(
            state: &state,
            action: action,
            env: env
        )

    // MARK: — Search text UI
    case .didChangeSearchText,
        .didClearSearch:
        // pure UI updates, no effects
        return searchInputReducer(state: &state, action: action)

    // MARK: — Triggering remote book search
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

    // MARK: — Handling remote book responses
    case .booksByTextLoaded,
        .booksByGenreLoaded,
        .booksByAuthorLoaded:
        return searchResultsResponseReducer(
            state: &state,
            action: action
        )

    // MARK: — Remote metadata (genres & authors)
    case .fetchRemoteGenres,
        .remoteGenresLoaded,
        .fetchRemoteAuthors,
        .remoteAuthorsLoaded:
        return remoteMetadataReducer(
            state: &state,
            action: action,
            env: env
        )

    // MARK: — Navigation / UI
    case .didSelectBook(let documentId):
        state.selectedBookID = documentId
        return .none

    case .dismissError:
        state.lastErrorMessage = nil
        return .none
    }
}

// MARK: — Recent Searches Reducer

private func recentSearchesReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    case .fetchRecentSearches:
        return .task {
            do {
                let recents = try await env.recentSearchService.load()
                return .recentSearchesLoaded(recents)
            } catch {
                return .recentSearchesLoaded([])
            }
        }

    case .addRecentSearch(let recent):
        return .merge(
            .fireAndForget { try? await env.recentSearchService.add(recent) },
            .task { .fetchRecentSearches }
        )

    case .recentSearchesLoaded(let recents):
        state.recentSearches = recents
        return .none

    case .removeRecentSearch(let query):
        return .task {
            try? await env.recentSearchService.remove(query)
            let recents = (try? await env.recentSearchService.load()) ?? []
            return .recentSearchesLoaded(recents)
        }

    default:
        return .none
    }
}

// MARK: — Local Metadata Reducer

private func localMetadataReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    case .fetchLocalGenres:
        state.genres = .loading
        return .task {
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
        return .task {
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

// MARK: — Search Input Reducer

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

// MARK: — Trigger Remote Search Reducer

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
    .task {
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

// MARK: — Handle Remote Response Reducer

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

// MARK: — Remote Metadata Reducer

@MainActor
private func remoteMetadataReducer(
    state: inout SearchState,
    action: SearchAction,
    env: SearchEnvironment
) -> Effect<SearchAction> {
    switch action {
    case .fetchRemoteGenres:
        state.genres = .loading
        return .task {
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
            return .fireAndForget {
                try? await env.genreStorage.save(items)
            }
        case .failure(let err):
            state.genres = .failure(err.localizedKey)
            return .none
        }

    case .fetchRemoteAuthors:
        state.authors = .loading
        return .task {
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
            return .fireAndForget {
                try? await env.authorStorage.save(items)
            }
        case .failure(let err):
            state.authors = .failure(err.localizedKey)
            return .none
        }

    default:
        return .none
    }
}
