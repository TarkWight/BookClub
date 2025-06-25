//
//  SearchState.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

struct SearchState: Equatable, Sendable {
    var filter: SearchFilter? = nil

    var isSearching: Bool { filter != nil }

    var recentSearches: [String] = []

    var genres: Loadable<[GenreItem]> = .idle
    var authors: Loadable<[AuthorItem]> = .idle

    var searchResults: Loadable<[BookDetailsItem]> = .idle

    var lastErrorMessage: String? = nil
    var selectedBookID: String? = nil
}
