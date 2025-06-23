//
//  LibraryState.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

enum Loadable<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failure(String)
}

struct LibraryState: Equatable, Sendable {
    var newBooks: Loadable<[BookDetailsItem]> = .idle
    var popularBooks: Loadable<[BookDetailsItem]> = .idle
    var selectedBookID: String?
}
