//
//  MainTabAction.swift
//  BookClub
//
//  Created by Tark Wight on 10.06.2025.
//

import Foundation

enum MainTabAction: Equatable {
    case tabSelected(Tab)
    case library(LibraryAction)
    case search(SearchAction)
    case bookmarks(BookmarksAction)
    case bookDetails(BookDetailsAction)
    case readSelected
    case logoutTapped
}
