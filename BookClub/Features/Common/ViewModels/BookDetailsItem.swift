//
//  BookDetailsItem.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

@MainActor
struct BookDetailsItem: Identifiable, Equatable, Codable {
    let id: Int64
    let documentId: String
    let title: String
    let coverURL: URL?
    let isNew: Bool
    let illustrationURL: URL?
    let isFavorite: Bool?
    let authorName: String?
    let description: String
}

extension BookDetailsItem: @preconcurrency HasPlaceholder {
    static func placeholder(id: String) -> BookDetailsItem {
        .init(
            id: Int64(id.hashValue),
            documentId: .placeholder(length: 5),
            title: .placeholder(length: 20),
            coverURL: nil,
            isNew: true,
            illustrationURL: nil,
            isFavorite: false,
            authorName: .authorPlaceholder(),
            description: .placeholder(length: 50)
        )
    }

    static func placeholderArray(count: Int) -> [BookDetailsItem] {
        (0..<count).map { index in
            BookDetailsItem.placeholder(id: "\(index)")
        }
    }
}
