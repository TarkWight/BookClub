//
//  ContentView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = Router()
    @State private var isChaptersPresented = false

    var body: some View {
        ZStack {
            switch router.currentScreen {
            case .auth:
                LogInView(router: router)
            case .mainTab:
                MainTabView(router: router, isChaptersPresented: $isChaptersPresented)
            case .bookDetails:
                BookDetailsView(router: router)
            case .reader:
                ReaderView(router: router, isChaptersPresented: $isChaptersPresented)
            case .search:
                SearchView(router: router)
            case .bookmarks:
                BookmarksView(router: router)
            default:
                EmptyView()
            }
        }
        .sheet(isPresented: $isChaptersPresented) {
            ChaptersView(isPresented: $isChaptersPresented)
        }
    }
}
