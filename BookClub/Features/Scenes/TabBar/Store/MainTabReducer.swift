//
//  MainTabReducer.swift
//  BookClub
//
//  Created by Tark Wight on 10.06.2025.
//

import Foundation

private enum CancellationID {
    static let libraryOnDisappear = "LibraryOnDisappear"
}

@MainActor
func mainTabReducer(
    state: inout MainTabState,
    action: MainTabAction,
    env: MainTabEnvironment
) -> Effect<MainTabAction> {
    switch action {

    case .tabSelected(let newTab):
        let leaveLibrary: Effect<MainTabAction> =
            state.selectedTab == .library && newTab != .library
            ? .fireAndForget(id: CancellationID.libraryOnDisappear) { }
                .map { _ in .library(.onDisappear) }
            : .none

        state.selectedTab = newTab
        return leaveLibrary

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
        return .fireAndForget(id: nil) {}

    case .logoutTapped:
        return .fireAndForget(id: nil) {}
    }
}
