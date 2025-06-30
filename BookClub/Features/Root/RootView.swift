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
            switch store.state.authStatus {
            case .unknown:
                ProgressView()
                    .onAppear { store.send(.appStarted) }

            case .unauthenticated:
                NavigationStack(path: store.binding(
                    get: \.path,
                    send: AppAction.pathChanged
                )) {
                    LoginView(
                        store: store.scope(
                            state: \.login,
                            action: AppAction.login
                        )
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
                }
                .task { store.send(.appStarted) }

            case .authenticated:
                NavigationStack(path: store.binding(
                    get: \.path,
                    send: AppAction.pathChanged
                )) {
                    MainTabView(
                        store: store.scope(
                            state: \.mainTab,
                            action: AppAction.mainTab
                        )
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
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

        case .library:
            LibraryView(
                store: store.scope(
                    state: \.mainTab.library,
                    action: { AppAction.mainTab(.library($0)) }
                )
            )

        case .search:
            SearchView(
                store: store.scope(
                    state: \.mainTab.search,
                    action: { AppAction.mainTab(.search($0)) }
                )
            )

        case .bookmarks:
            BookmarksView(
//                store: store.scope(
//                    state: \.mainTab.bookmarks,
//                    action: { AppAction.mainTab(.bookmarks($0)) }
//                )
            )

        case .bookDetails:
            BookDetailsView(
                store: store.scope(
                    state: \.mainTab.bookDetails,
                    action: { AppAction.mainTab(.bookDetails($0)) }
                )
            )

        case .reader:
            ReaderView(
//                store: store.scope(
//                    state: \.mainTab.bookDetails,
//                    action: { AppAction.mainTab(.bookDetails($0)) }
//                )
            )

        case .chapters:
            ChaptersView(
//                store: store.scope(
//                    state: \.mainTab.bookDetails,
//                    action: { AppAction.mainTab(.bookDetails($0)) }
//                )
            )
        }
    }
}
