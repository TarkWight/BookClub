//
//  BookmarksAction.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

enum BookmarksAction: Equatable {
    case onAppear
    case onDisappear

    case loadLocalQuotes
    case localQuotesLoaded(Result<[QuoteItem], NetworkError>)

    case deleteQuote(id: Int64)

    case loadReadingProgress
    case readingProgressLoaded(Result<[String: Double], NetworkError>)

    case loadFavorites
    case favoritesLoaded(Result<Set<Int64>, NetworkError>)

    case quoteTapped(documentId: String)
    case continueReading(documentId: String)
    
    case bookMetadataLoaded(documentId: String, book: Book)

    case clearError

    case noop
}
