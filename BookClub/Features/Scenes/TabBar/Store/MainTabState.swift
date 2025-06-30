//
//  MainTabState.swift
//  BookClub
//
//  Created by Tark Wight on 10.06.2025.
//

import Foundation

struct MainTabState: Equatable, Sendable {
    var selectedTab: Tab = .library
    var library: LibraryState = .init()
    var search: SearchState = .init()
    var bookDetails: BookDetailsState = .init()
    var bookmarks: BookmarksState = .init()
}
