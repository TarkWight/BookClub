//
//  SearchState.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

struct SearchState: Equatable, Sendable {
    var genres: Loadable<GenreItem> = .idle
    var authors: Loadable<AuthorItem> = .idle
    var recentSearches: Loadable<RecentSearches> = .idle
    
    var selectedGenre: String?
    var selectedAuthor: String?
    var selectedRecentSearch: String?
    
    var selectedBookID: String?
}

struct GenreItem: Identifiable, Equatable, Codable {
    var id: Int64
    var name: String
}

struct AuthorItem: Identifiable, Equatable, Codable {
    var id: Int64
    var name: String
    var imageUrl: String?
}

struct RecentSearches: Identifiable, Equatable, Codable {
    var id: Int64
    var name: String
}
