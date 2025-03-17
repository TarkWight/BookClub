//
//  BookCoversMock.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import Foundation

struct BookCover: Identifiable {
    let id: UUID = UUID()
    let imageName: String
}

struct BookCoversMock {
    static let allBookCovers: [BookCover] = [
        "Cover1", "Cover2", "Cover3",
        "Cover4", "Cover5", "Cover6",
        "Cover7", "Cover8", "Cover9",
        "Cover10", "Cover11", "Cover12",
        "Cover13", "Cover14", "Cover15"
    ].map { BookCover(imageName: $0) }

    static func getBookCovers(for count: Count) -> [BookCover] {
        switch count {
        case .three:
            return Array(allBookCovers.prefix(3))
        case .five:
            return Array(allBookCovers.prefix(5))
        case .all:
            return allBookCovers
        }
    }
    
    enum Count {
        case three
        case five
        case all
    }
}
