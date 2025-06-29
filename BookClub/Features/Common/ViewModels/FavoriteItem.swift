//
//  FavoriteItem.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct FavoriteItem: Identifiable, Codable {
    let id: Int
    let documentId: String
    let bookId: Int
}
