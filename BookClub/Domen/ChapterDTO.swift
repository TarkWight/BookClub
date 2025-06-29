//
//  ChapterItem.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct ChapterDTO: Identifiable, Codable, Equatable {
    let id: Int64
    let documentId: String
    let order: Int
    let title: String
    let text: String
    let status: ChapterStatus
}
