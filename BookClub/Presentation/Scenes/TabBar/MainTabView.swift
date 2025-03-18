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
        VStack(spacing: 0) {
            currentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            TabBarView(
                selectedTab: $selectedTab,
                onTabSelected: handleTabSelection,
                onReadSelected: { router.navigateTo(.reader) },
                onLogout: router.logout
            )
            .padding(.bottom, 42)
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func currentView() -> some View {
        switch selectedTab {
        case .library:
            LibraryView(router: router)
        case .search:
            SearchView(router: router)
        case .bookmarks:
            BookmarksView(router: router)
        }
    }

    private func handleTabSelection(_ tab: Tab) {
        selectedTab = tab
    }
}

#Preview {
    MainTabView(router: Router(), isChaptersPresented: .constant(false))
}
