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
    var bookmarks: BookmarksState = .init()
}

// Bookmarks feature (заглушки)
struct BookmarksState: Equatable {}
enum BookmarksAction: Equatable {}
struct BookmarksEnvironment { /* сюда можно инжектить storageService */  }
func bookmarksReducer(
    state: inout BookmarksState,
    action: BookmarksAction,
    env: BookmarksEnvironment
) -> Effect<BookmarksAction> {
    // TODO: реализовать закладки
    return .none
}
