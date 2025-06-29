//
//  MainTabReducer.swift
//  BookClub
//
//  Created by Tark Wight on 10.06.2025.
//

import Foundation

@MainActor
func mainTabReducer(
    state: inout MainTabState,
    action: MainTabAction,
    env: MainTabEnvironment
) -> Effect<MainTabAction> {
    switch action {

    case .tabSelected(let tab):
        state.selectedTab = tab
        return .none

    case .library(let libAction):
        return libraryReducer(
            state: &state.library,
            action: libAction,
            env: env.libraryEnv
        )
        .map { inner in
            switch inner {
            case .bookDetails(let bdAction):
                return .bookDetails(bdAction)
            default:
                return .library(inner)
            }
        }

    case .search(let searchAction):
        return searchReducer(
            state: &state.search,
            action: searchAction,
            env: env.searchEnv
        )
        .map(MainTabAction.search)

    case .bookDetails(let bookDetailsAction):
        return bookDetailsReducer(
            state: &state.bookDetails,
            action: bookDetailsAction,
            env: env.bookDetailsEnv
        )
        .map(MainTabAction.bookDetails)

    case .bookmarks(let bookmarksAction):
        return bookmarksReducer(
            state: &state.bookmarks,
            action: bookmarksAction,
            env: env.bookmarksEnv
        )
        .map(MainTabAction.bookmarks)

    case .readSelected:
        // Навигация обрабатывается на уровне AppReducer через MainTabAction.readSelected
        return .fireAndForget {}

    case .logoutTapped:
        // Аналогично — прокидываем MainTabAction.logoutTapped наверх
        return .fireAndForget {}
    }
}
