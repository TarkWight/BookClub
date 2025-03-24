//
//  ChapterIndex.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import Foundation

enum ChapterReadState: String, Codable {
    case unread
    case reading
    case read
}

struct ChapterIndex: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let chunkIndex: Int
    var state: ChapterReadState = .unread

    init(title: String, chunkIndex: Int, state: ChapterReadState = .unread) {
        self.id = UUID()
        self.title = title
        self.chunkIndex = chunkIndex
        self.state = state
    }
}
