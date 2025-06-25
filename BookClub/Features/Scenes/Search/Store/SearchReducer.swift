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
    case .fetchRecentSearches:
        return .task {
            do {
                let recents = try await env.recentSearchService.load()
                return .recentSearchesLoaded(recents)
            } catch {
                return .recentSearchesLoaded([])
            }
        }

    case .recentSearchesLoaded(let recents):
        state.recentSearches = recents
        return .none

    // MARK: — Local DB (genres/authors)
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

    // MARK: — UI
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

    case .didSelectRecentSearch(let query):
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByTitle(query: query),
                        decoder: JSONDecoder()
                    )
                return .booksByTextLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByTextLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByTextLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .didSelectGenre(let genre):
        state.filter = .genre(genre)
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByGenre(id: Int(genre.id)),
                        decoder: JSONDecoder()
                    )
                return .booksByGenreLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByGenreLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByGenreLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .didSelectAuthor(let author):
        state.filter = .author(author)
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByAuthor(id: Int(author.id)),
                        decoder: JSONDecoder()
                    )
                return .booksByAuthorLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByAuthorLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByAuthorLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .didTapSearch:
        guard case let .text(query) = state.filter else { return .none }
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByTitle(query: query),
                        decoder: JSONDecoder()
                    )
                return .booksByTextLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByTextLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByTextLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .didSelectBook(let documentId):
        state.selectedBookID = documentId
        return .none

    // MARK: — Network Responses
    case .booksByTextLoaded(let result):
        switch result {
        case .success(let items):
            state.searchResults = .loaded(items)
        case .failure(let err):
            state.searchResults = .failure(err.localizedKey)
        }
        return .none

    case .booksByGenreLoaded(let result):
        switch result {
        case .success(let items):
            state.searchResults = .loaded(items)
        case .failure(let err):
            state.searchResults = .failure(err.localizedKey)
        }
        return .none

    case .booksByAuthorLoaded(let result):
        switch result {
        case .success(let items):
            state.searchResults = .loaded(items)
        case .failure(let err):
            state.searchResults = .failure(err.localizedKey)
        }
        return .none

    // MARK: — Explicit request cases
    case .fetchBooksByText(let query):
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByTitle(query: query),
                        decoder: JSONDecoder()
                    )
                return .booksByTextLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByTextLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByTextLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .fetchBooksByGenre(let genre):
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByGenre(id: Int(genre.id)),
                        decoder: JSONDecoder()
                    )
                return .booksByGenreLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByGenreLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByGenreLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .fetchBooksByAuthor(let author):
        state.searchResults = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        SearchConfig.booksByAuthor(id: Int(author.id)),
                        decoder: JSONDecoder()
                    )
                return .booksByAuthorLoaded(.success(wrapper.data))
            } catch let netErr as NetworkError {
                return .booksByAuthorLoaded(.failure(netErr))
            } catch {
                let urlErr = (error as? URLError) ?? URLError(.unknown)
                return .booksByAuthorLoaded(.failure(.otherURL(urlErr)))
            }
        }

    case .dismissError:
        state.lastErrorMessage = nil
        return .none

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
                do {
                    try await env.genreStorage.save(items)
                } catch {
                }
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
                do {
                    try await env.authorStorage.save(items)
                } catch {
                    print("Не удалось сохранить авторов в БД: \(error)")
                }
            }
        case .failure(let err):
            state.authors = .failure(err.localizedKey)
            return .none
        }
    }
}
