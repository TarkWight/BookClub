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

    var loginEnv: LoginEnvironment {
        LoginEnvironment(authService: authService)
    }

    var libraryEnv: LibraryEnvironment {
        LibraryEnvironment(networkClient: networkClient)
    }

    var searchEnv: SearchEnvironment {
        SearchEnvironment()
    }

    var bookmarksEnv: BookmarksEnvironment {
        BookmarksEnvironment()
    }

    var mainTabEnv: MainTabEnvironment {
        MainTabEnvironment(
            libraryEnv: libraryEnv,
            searchEnv: searchEnv,
            bookmarksEnv: bookmarksEnv)
    }
}
