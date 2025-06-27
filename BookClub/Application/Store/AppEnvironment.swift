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

    let bookStorage: BookStorageServiceProtocol

    let genreStorage: GenreStorageServiceProtocol
    let authorStorage: AuthorStorageServiceProtocol
    let recentSearchService: RecentSearchServiceProtocol

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
        BookmarksEnvironment()
    }

    var mainTabEnv: MainTabEnvironment {
        MainTabEnvironment(
            libraryEnv: libraryEnv,
            searchEnv: searchEnv,
            bookmarksEnv: bookmarksEnv
        )
    }
}
