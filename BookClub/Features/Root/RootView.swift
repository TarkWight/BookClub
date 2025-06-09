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
//      .navigationDestination(for: AppRoute.self) { route in
//        switch route {
//        case .mainTab:
//          MainTabView(
//            store: store.scope(
//              state: \.library,
//              action: AppAction.library
//            )
//          )
//        case .library:
//          LibraryView(
//            store: store.scope(
//              state: \.library,
//              action: AppAction.library
//            )
//          )
//        case .search:
//          SearchView(
//            store: store.scope(
//              state: \.search,
//              action: AppAction.search
//            )
//          )
//        case .bookmarks:
//          BookmarksView(
//            store: store.scope(
//              state: \.bookmarks,
//              action: AppAction.bookmarks
//            )
//          )
//        case .bookDetails(let id):
//          BookDetailView(bookID: id)
//        case .reader(let bookID, let chapterID):
//          ReaderView(bookID: bookID, chapterID: chapterID)
//        case .chapters(let bookID):
//          ChaptersView(bookID: bookID)
//        default:
//          EmptyView()
//        }
//      }
    }
  }
}
