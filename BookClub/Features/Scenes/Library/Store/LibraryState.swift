//
//  LibraryState.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

struct LibraryState: Equatable, Sendable {
    var bookDetails: BookDetailsState = .init()
    var newBooks: Loadable<[BookDetailsItem]> = .idle
    var popularBooks: Loadable<[BookDetailsItem]> = .idle
    var selectedBookID: String?
}
