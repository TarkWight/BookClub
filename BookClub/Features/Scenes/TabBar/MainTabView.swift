//
//  MainTabView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var store: Store<MainTabState, MainTabAction>

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            tabBar
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch store.state.selectedTab {
        case .library:
            LibraryView(
                store: store.scope(
                    state: \.library,
                    action: MainTabAction.library
                )
            )
        case .search:
            SearchView(
                store: store.scope(
                    state: \.search,
                    action: MainTabAction.search
                )
            )
        case .bookmarks:
            BookmarksView(
//                store: store.scope(
//                    state: \.bookmarks,
//                    action: MainTabAction.bookmarks
//                )
            )
        }
//        .ignoresSafeArea(.all, edges: .bottom)
    }

    private var tabBar: some View {
        TabBarView(
            selectedTab: store.binding(
                get: \.selectedTab,
                send: MainTabAction.tabSelected
            ),
            onTabSelected: { store.send(.tabSelected($0)) },
            onReadSelected: { store.send(.readSelected) },
            onLogout: { store.send(.logoutTapped) }
        )
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, Constants.bottomPadding)
    }
}

private extension MainTabView {
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat   = 8
    }
}

#Preview {
    MainTabView(store: Store<MainTabState, MainTabAction>(
        initialState: .init(),
        reducer: { _, _ in
            return .none
        }
    ))
}
