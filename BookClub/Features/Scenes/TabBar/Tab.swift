//
//  Tab.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

enum Tab: CaseIterable {
    case library, search, bookmarks

    var icon: Image {
        switch self {
        case .library: return AppImages.library
        case .search: return AppImages.search
        case .bookmarks: return AppImages.bookmarks
        }
    }
}
