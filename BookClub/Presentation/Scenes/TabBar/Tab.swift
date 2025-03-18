//
//  Tab.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

enum Tab: CaseIterable {
    case library, search, bookmarks

    var icon: String {
        switch self {
        case .library: return UIKitAssets.imageLibrary
        case .search: return UIKitAssets.imageSearch
        case .bookmarks: return UIKitAssets.imageBookmarks
        }
    }
}
