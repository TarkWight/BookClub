//
//  AppEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

struct AppEnvironment {
    let authService: AuthServiceProtocol
    let networkClient: NetworkClientProtocol
    let readingSession: ReadingSessionProtocol

    let bookStorage: BookStorageServiceProtocol
    let chapterStorage: ChapterStorageServiceProtocol

    let genreStorage: GenreStorageServiceProtocol
    let authorStorage: AuthorStorageServiceProtocol
    let recentSearchService: RecentSearchServiceProtocol
    let quoteStorage: QuoteStorageServiceProtocol

    var loginEnv: LoginEnvironment {
        LoginEnvironment(authService: authService)
    }

    var libraryEnv: LibraryEnvironment {
        LibraryEnvironment(networkClient: networkClient, storage: bookStorage)
    }

    var searchEnv: SearchEnvironment {
        SearchEnvironment(
            networkClient: networkClient,
            genreStorage: genreStorage,
            authorStorage: authorStorage,
            recentSearchService: recentSearchService
        )
    }

    var bookmarksEnv: BookmarksEnvironment {
        BookmarksEnvironment(
            networkClient: networkClient,
            quoteStorage: quoteStorage,
            bookStorage: bookStorage,
            chapterStorage: chapterStorage
        )
    }

    var bookDetailsEnv: BookDetailsEnvironment {
        BookDetailsEnvironment(
            chapterStorage: chapterStorage,
            readingSession: readingSession,
            networkClient: networkClient
        )
    }

    var mainTabEnv: MainTabEnvironment {
        MainTabEnvironment(
            libraryEnv: libraryEnv,
            searchEnv: searchEnv,
            bookmarksEnv: bookmarksEnv,
            bookDetailsEnv: bookDetailsEnv
        )
    }
}
