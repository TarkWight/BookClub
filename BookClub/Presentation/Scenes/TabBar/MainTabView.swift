//
//  MainTabView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var router: Router
    @Binding var isChaptersPresented: Bool
    @State private var selectedTab: Tab = .library

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            tabBar
        }
    }
}

// MARK: - UI Components
private extension MainTabView {
    var contentView: some View {
        currentView()
            .ignoresSafeArea(.all, edges: .bottom)
    }

    var tabBar: some View {
        TabBarView(
            selectedTab: $selectedTab,
            onTabSelected: handleTabSelection,
            onReadSelected: { router.navigateTo(.reader) },
            onLogout: router.logout
        )
        .padding(.horizontal, Constants.tabBarHorizontalPadding)
        .padding(.bottom, Constants.tabBarBottomPadding)
    }

    @ViewBuilder
    func currentView() -> some View {
        switch selectedTab {
        case .library:
            LibraryView(router: router)
        case .search:
            SearchView(router: router)
        case .bookmarks:
            BookmarksView(router: router)
        }
    }

    func handleTabSelection(_ tab: Tab) {
        selectedTab = tab
    }
}

// MARK: - Constants
private extension MainTabView {
    enum Constants {
        static let tabBarHorizontalPadding: CGFloat = 16
        static let tabBarBottomPadding: CGFloat = 8
    }
}

#Preview {
    MainTabView(router: Router(), isChaptersPresented: .constant(false))
}
