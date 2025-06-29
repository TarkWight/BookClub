//
//  LibraryReducer.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Alamofire
import Foundation

@MainActor
func libraryReducer(
    state: inout LibraryState,
    action: LibraryAction,
    env: LibraryEnvironment
) -> Effect<LibraryAction> {
    switch action {
    // MARK: — Local DB: New Books
    case .fetchLocalNewBooks,
        .localNewBooksLoaded:
        return localNewBooksReducer(state: &state, action: action, env: env)

    // MARK: — Local DB: Popular Books
    case .fetchLocalPopularBooks,
        .localPopularBooksLoaded:
        return localPopularBooksReducer(state: &state, action: action, env: env)

    // MARK: — Network: Request New Books & Response
    case .requestNewBooks,
        .newBooksResponse:
        return networkNewBooksReducer(state: &state, action: action, env: env)

    // MARK: — Network: Request Popular Books & Response
    case .requestPopularBooks,
        .popularBooksResponse:
        return networkPopularBooksReducer(
            state: &state,
            action: action,
            env: env
        )

    // MARK: — UI

    case .didSelectBook(let documentId):
        var all: [BookDetailsItem] = []
        if case .loaded(let arr) = state.newBooks { all += arr }
        if case .loaded(let arr) = state.popularBooks { all += arr }

        guard let item = all.first(where: { $0.documentId == documentId })
        else {
            return .none
        }

        state.bookDetails = .init()

        let cfg = BookDetailsAction.configure(
            bookId: Int(item.id),
            documentId: item.documentId,
            title: item.title,
            author: item.authorName ?? LocalizedKey.authorPlaceholder,
            description: item.description,
            coverURL: item.coverURL
        )

        return .task { .bookDetails(cfg) }

    case .bookDetails:
        return .none

    case .didConfigureBookDetails(let cfgAction):
        return .task {
            .bookDetails(cfgAction)
        }
    }

}

// MARK: — Local New Books Reducer

private func localNewBooksReducer(
    state: inout LibraryState,
    action: LibraryAction,
    env: LibraryEnvironment
) -> Effect<LibraryAction> {
    switch action {
    case .fetchLocalNewBooks:
        guard case .idle = state.newBooks else { return .none }
        state.newBooks = .loading
        return .task {
            do {
                let books = try await env.storage.fetch(isNew: true)
                if books.isEmpty {
                    return .requestNewBooks
                }
                let items = books.map { $0.toDetailsItem() }
                return .localNewBooksLoaded(items)
            } catch {
                return .requestNewBooks
            }
        }

    case .localNewBooksLoaded(let items):
        state.newBooks = .loaded(items)
        return .none

    default:
        return .none
    }
}

// MARK: — Local Popular Books Reducer

private func localPopularBooksReducer(
    state: inout LibraryState,
    action: LibraryAction,
    env: LibraryEnvironment
) -> Effect<LibraryAction> {
    switch action {
    case .fetchLocalPopularBooks:
        guard case .idle = state.popularBooks else { return .none }
        state.popularBooks = .loading
        return .task {
            do {
                let books = try await env.storage.fetch(isNew: false)
                if books.isEmpty {
                    return .requestPopularBooks(page: 1)
                }
                let items = books.map { $0.toDetailsItem() }
                return .localPopularBooksLoaded(items)
            } catch {
                return .requestPopularBooks(page: 1)
            }
        }

    case .localPopularBooksLoaded(let items):
        state.popularBooks = .loaded(items)
        return .fireAndForget {
            let domain = items.map { Book(from: $0) }
            guard !domain.isEmpty else { return }
            try? await env.storage.save(domain)
        }

    default:
        return .none
    }
}

// MARK: — Network New Books Reducer

@MainActor private func networkNewBooksReducer(
    state: inout LibraryState,
    action: LibraryAction,
    env: LibraryEnvironment
) -> Effect<LibraryAction> {
    switch action {
    case .requestNewBooks:
        state.newBooks = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        LibraryConfig.newBooks,
                        decoder: JSONDecoder()
                    )
                return .newBooksResponse(.success(wrapper.data))
            } catch let err as NetworkError {
                return .newBooksResponse(.failure(err))
            } catch {
                let wrapped = AFError.sessionInvalidated(error: error)
                return .newBooksResponse(.failure(.afError(wrapped)))
            }
        }

    case .newBooksResponse(let result):
        switch result {
        case .success(let items):
            state.newBooks = .loaded(items)
            return .fireAndForget {
                let domain = items.map { Book(from: $0) }
                guard !domain.isEmpty else { return }
                try? await env.storage.save(domain)
            }
        case .failure(let error):
            state.newBooks = .failure(error.localizedKey)
            return .none
        }

    default:
        return .none
    }
}

// MARK: — Network Popular Books Reducer

@MainActor private func networkPopularBooksReducer(
    state: inout LibraryState,
    action: LibraryAction,
    env: LibraryEnvironment
) -> Effect<LibraryAction> {
    switch action {
    case .requestPopularBooks(let page):
        state.popularBooks = .loading
        return .task {
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        LibraryConfig.list(page: page, pageSize: 10),
                        decoder: JSONDecoder()
                    )
                return .popularBooksResponse(.success(wrapper.data))
            } catch let err as NetworkError {
                return .popularBooksResponse(.failure(err))
            } catch {
                let wrapped = AFError.sessionInvalidated(error: error)
                return .popularBooksResponse(.failure(.afError(wrapped)))
            }
        }

    case .popularBooksResponse(let result):
        switch result {
        case .success(let items):
            state.popularBooks = .loaded(items)
            return .fireAndForget {
                let domain = items.map { Book(from: $0) }
                guard !domain.isEmpty else { return }
                try? await env.storage.save(domain)
            }
        case .failure(let error):
            state.popularBooks = .failure(error.localizedKey)
            return .none
        }

    default:
        return .none
    }
}

// MARK: — Helpers: Domain Mapping

extension Book {
    fileprivate func toDetailsItem() -> BookDetailsItem {
        BookDetailsItem(
            id: id,
            documentId: documentId,
            title: title,
            coverURL: coverURL,
            isNew: isNew,
            illustrationURL: illustrationURL,
            isFavorite: isFavorite,
            authorName: authorName,
            description: description
        )
    }
}

extension BookDetailsItem {
    fileprivate init(fromStored item: Book) {
        self = item.toDetailsItem()
    }
}

extension Book {
    fileprivate init(from details: BookDetailsItem) {
        self.init(
            id: details.id,
            documentId: details.documentId,
            title: details.title,
            coverURL: details.coverURL,
            illustrationURL: details.illustrationURL,
            isFavorite: details.isFavorite,
            isNew: details.isNew,
            authorName: details.authorName,
            description: details.description
        )
    }
}
