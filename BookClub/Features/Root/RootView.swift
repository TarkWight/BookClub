//
//  RootView.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        Group {
            switch store.current.authStatus {
            case .unknown:
                ProgressView()
                    .onAppear { store.send(.appStarted) }

            case .unauthenticated:
                NavigationStack(
                    path: store.binding(
                        get: \.path,
                        send: AppAction.pathChanged
                    )
                ) {
                    LoginView(
                        store: store.scope(
                            state: \.login,
                            action: AppAction.login
                        )
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        routeDestination(route)
                    }
                }
                .task {
                    store.send(.appStarted)
                }

            case .authenticated:
                NavigationStack {
                    MainTabView(
                        store: store.scope(
                            state: \.mainTab,
                            action: AppAction.mainTab
                        )
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: AppRoute) -> some View {
        switch route {
        case .auth:
            LoginView(
                store: store.scope(
                    state: \.login,
                    action: AppAction.login
                )
            )
        case .mainTab:
            MainTabView(
                store: store.scope(
                    state: \.mainTab,
                    action: AppAction.mainTab
                )
            )
        case .bookDetails:
            BookDetailsView( /*bookID: bookID*/)
        case .reader:
            ReaderView( /*bookID: bookID, chapterID: chapterID*/)
        case .chapters:
            ChaptersView( /*bookID: bookID*/)
        case .library, .search, .bookmarks:
            EmptyView()
        }
    }
}
