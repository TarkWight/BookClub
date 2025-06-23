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

    // MARK: – Load from local DB

    case .fetchLocalNewBooks:
        guard case .idle = state.newBooks else { return .none }
        print("[Library] Fetching NEW books from local DB…")
        state.newBooks = .loading

        return .task {
            do {
                let books = try await env.storage.fetch(isNew: true)
                if books.isEmpty {
                    print(
                        "[Library] No NEW books locally, falling back to network"
                    )
                    return .requestNewBooks
                }
                print("[Library] ✓ Loaded \(books.count) NEW books locally")
                let items = books.map { book in
                    BookDetailsItem(
                        id: book.id,
                        documentId: book.documentId,
                        title: book.title,
                        coverURL: book.coverURL,
                        createdAt: ISO8601DateFormatter().string(
                            from: book.createdAt
                        ),
                        updatedAt: ISO8601DateFormatter().string(
                            from: book.updatedAt
                        ),
                        publishedAt: ISO8601DateFormatter().string(
                            from: book.createdAt
                        ),
                        isNew: book.isNew,
                        illustrationURL: book.illustrationURL
                    )
                }
                return .localNewBooksLoaded(items)
            } catch {
                print("[Library] ✗ Local NEW-books fetch failed: \(error)")
                return .requestNewBooks
            }
        }

    case .localNewBooksLoaded(let items):
        print("[Library] Updating state with \(items.count) NEW local books")
        state.newBooks = .loaded(items)
        return .none

    case .fetchLocalPopularBooks:
        guard case .idle = state.popularBooks else { return .none }
        print("[Library] Fetching POPULAR books from local DB…")
        state.popularBooks = .loading

        return .task {
            do {
                let books = try await env.storage.fetch(isNew: false)
                if books.isEmpty {
                    print(
                        "[Library] No POPULAR books locally, falling back to network"
                    )
                    return .requestPopularBooks(page: 1)
                }
                print("[Library] ✓ Loaded \(books.count) POPULAR books locally")
                let items = books.map { book in
                    BookDetailsItem(
                        id: book.id,
                        documentId: book.documentId,
                        title: book.title,
                        coverURL: book.coverURL,
                        createdAt: ISO8601DateFormatter().string(
                            from: book.createdAt
                        ),
                        updatedAt: ISO8601DateFormatter().string(
                            from: book.updatedAt
                        ),
                        publishedAt: ISO8601DateFormatter().string(
                            from: book.createdAt
                        ),
                        isNew: book.isNew,
                        illustrationURL: book.illustrationURL
                    )
                }
                return .localPopularBooksLoaded(items)
            } catch {
                print("[Library] ✗ Local POPULAR-books fetch failed: \(error)")
                return .requestPopularBooks(page: 1)
            }
        }

    case .localPopularBooksLoaded(let items):
        print(
            "[Library] Updating state with \(items.count) POPULAR local books"
        )
        state.popularBooks = .loaded(items)
        return .none

    // MARK: – Network requests

    case .requestNewBooks:
        print("[Library] Requesting NEW books from network…")
        state.newBooks = .loading

        return .task {
            print("[Network] GET \(LibraryConfig.newBooks)")
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        LibraryConfig.newBooks,
                        decoder: JSONDecoder()
                    )
                let items = wrapper.data
                print("[Network] ✓ NEW books received: count=\(items.count)")
                return .newBooksResponse(.success(items))
            } catch let error as NetworkError {
                print(
                    "[Network] ✗ NEW books failed with NetworkError: \(error)"
                )
                return .newBooksResponse(.failure(error))
            } catch {
                print("[Network] ✗ NEW books unexpected error: \(error)")
                let wrapped = AFError.sessionInvalidated(error: error)
                return .newBooksResponse(.failure(.afError(wrapped)))
            }
        }

    case .newBooksResponse(let result):
        switch result {
        case .success(let items):
            print("[Library] State update: NEW books loaded successfully")
            state.newBooks = .loaded(items)
            return .fireAndForget {
                let formatter = ISO8601DateFormatter()
                let domain = items.compactMap { item -> Book? in
                    guard
                        let created = formatter.date(from: item.createdAt),
                        let updated = formatter.date(from: item.updatedAt),
                        let published = formatter.date(from: item.publishedAt)
                    else {
                        print(
                            "[Library] ✗ Date parsing failed for item \(item.id)"
                        )
                        return nil
                    }
                    return Book(
                        id: item.id,
                        documentId: item.documentId,
                        title: item.title,
                        coverURL: item.coverURL,
                        illustrationURL: item.illustrationURL,
                        isNew: item.isNew,
                        createdAt: created,
                        publishedAt: published,
                        updatedAt: updated
                    )
                }
                if !domain.isEmpty {
                    do {
                        try await env.storage.save(domain)
                        print("[Library] ✓ NEW books saved to DB")
                    } catch {
                        print(
                            "[Library] ✗ Saving NEW books to DB failed: \(error)"
                        )
                    }
                }
            }
        case .failure(let error):
            print(
                "[Library] State update: NEW books failed with \(error.localizedKey)"
            )
            state.newBooks = .failure(error.localizedKey)
            return .none
        }

    case .requestPopularBooks(let page):
        print("[Library] Requesting POPULAR books from network (page \(page))…")
        state.popularBooks = .loading

        return .task {
            print(
                "[Network] GET \(LibraryConfig.list(page: page, pageSize: 10))"
            )
            do {
                let wrapper: StrapiResponse<[BookDetailsItem]> =
                    try await env.networkClient.request(
                        LibraryConfig.list(page: page, pageSize: 10),
                        decoder: JSONDecoder()
                    )
                let items = wrapper.data
                print(
                    "[Network] ✓ POPULAR books received: count=\(items.count)"
                )
                return .popularBooksResponse(.success(items))
            } catch let error as NetworkError {
                print(
                    "[Network] ✗ POPULAR books failed with NetworkError: \(error)"
                )
                return .popularBooksResponse(.failure(error))
            } catch {
                print("[Network] ✗ POPULAR books unexpected error: \(error)")
                let wrapped = AFError.sessionInvalidated(error: error)
                return .popularBooksResponse(.failure(.afError(wrapped)))
            }
        }

    case .popularBooksResponse(let result):
        switch result {
        case .success(let items):
            print("[Library] State update: POPULAR books loaded successfully")
            state.popularBooks = .loaded(items)
        case .failure(let error):
            print(
                "[Library] State update: POPULAR books failed with \(error.localizedKey)"
            )
            state.popularBooks = .failure(error.localizedKey)
        }
        return .none

    case .didSelectBook(let documentId):
        print("[Library] Book selected: \(documentId)")
        state.selectedBookID = documentId
        return .none
    }
}
