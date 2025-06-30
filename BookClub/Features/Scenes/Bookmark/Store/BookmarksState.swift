//
//  BookmarksState.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

struct BookmarksState: Equatable, Sendable {
    var didLoadOnAppear: Bool = false

    var quotes: Loadable<[QuoteItem]> = .idle

    var readingProgress: Loadable<[String: Double]> = .idle

    var favorites: Loadable<Set<Int64>> = .idle

    var selectedDocumentId: String? = nil
    var booksByDocumentId: [String: Book] = [:]
    var booksById: [Int64: BookDetailsItem] = [:]

    var currentReadingDocumentId: String? = nil
    var currentReadingId: Int64? = nil

    var errorMessage: String? = nil
}
