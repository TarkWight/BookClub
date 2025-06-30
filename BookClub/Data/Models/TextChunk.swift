//
//  TextChunk.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import Foundation

struct TextChunk: Identifiable {
    let id: String
    let documentId: String
    let chapterOrder: Int
    let index: Int
    let text: String
}
