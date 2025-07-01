//
//  AppRoute.swift
//  BookClub
//
//  Created by Tark Wight on 07.06.2025.
//

import Foundation

enum AppRoute: Hashable {
    case auth
    case mainTab
    case library
    case search
    case bookmarks
    case bookDetails
    case reader
    case chapters
}
// auth>mainTab
// mainTab>[library, search, bookmarks]
// mainTab>reader
// library>bookDetails
// search>bookDetails
// bookDetails>reader
// bookDetails>chapters
// search>bookDetails
// bookmarks>reader
// reader>chapters
