//
//  QuoteStorageServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

protocol QuoteStorageServiceProtocol: Sendable {
    func fetchQuotes(forBookId bookId: Int64?) async throws -> [QuoteEntity]
    func save(quotes: [QuoteItem]) async throws
    func deleteQuote(id: Int64) async throws
    func deleteAllQuotes(forBookId bookId: Int64?) async throws
}
