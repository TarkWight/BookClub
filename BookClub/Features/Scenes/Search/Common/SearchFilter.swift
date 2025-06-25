//
//  SearchFilter.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import Foundation

enum SearchFilter: Equatable, Sendable {
    case text(String)
    case genre(GenreItem)
    case author(AuthorItem)
}
