//
//  Tab.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

enum Tab: CaseIterable {
    case library, search, bookmarks

    var icon: UIKitAssets.Icon {
        switch self {
        case .library: return UIKitAssets.Icon.library
        case .search: return UIKitAssets.Icon.search
        case .bookmarks: return UIKitAssets.Icon.bookmarks
        }
    }
}
