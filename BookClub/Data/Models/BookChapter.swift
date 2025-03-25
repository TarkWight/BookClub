//
//  BookChapter.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import Foundation

struct BookChapter: Identifiable, Codable {
    var id = UUID()
    let title: String
    let chunkIndex: Int
}
