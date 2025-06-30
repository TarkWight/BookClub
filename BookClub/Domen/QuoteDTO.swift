//
//  QuoteDTO.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

struct QuoteItem: Sendable, Equatable, Identifiable {
    let id: Int64
    let documentId: String
    let text: String
    let bookId: Int64
}
