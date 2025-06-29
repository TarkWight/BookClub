//
//  LibraryAction.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

enum LibraryAction: Equatable {
    case onAppear
    case onDisappear

    // MARK: – Local storage (DB)
    case fetchLocalNewBooks
    case localNewBooksLoaded([BookDetailsItem])

    case fetchLocalPopularBooks
    case localPopularBooksLoaded([BookDetailsItem])

    // MARK: – Network (API)
    case requestNewBooks
    case newBooksResponse(Result<[BookDetailsItem], NetworkError>)

    case requestPopularBooks(page: Int)
    case popularBooksResponse(Result<[BookDetailsItem], NetworkError>)

    // MARK: – Navigation
    case bookDetails(BookDetailsAction)
    case didSelectBook(documentId: String)
    case didConfigureBookDetails(BookDetailsAction)
}
