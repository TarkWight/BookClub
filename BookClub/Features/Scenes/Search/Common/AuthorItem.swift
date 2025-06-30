//
//  AuthorItem.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import Foundation

struct AuthorItem: Identifiable, Equatable, Codable {
    var id: Int64
    var documentId: String
    var name: String
    var imageUrl: String?
}
