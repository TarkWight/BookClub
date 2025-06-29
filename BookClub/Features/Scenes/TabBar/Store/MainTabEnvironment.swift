//
//  MainTabEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 10.06.2025.
//

import Foundation

struct MainTabEnvironment: Sendable {
    let libraryEnv: LibraryEnvironment
    let searchEnv: SearchEnvironment
    let bookmarksEnv: BookmarksEnvironment
    let bookDetailsEnv: BookDetailsEnvironment
}
