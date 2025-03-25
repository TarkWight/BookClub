//
//  TextChunk.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import Foundation

struct TextChunk: Identifiable, Equatable {
    let index: Int
    let text: String

    var id: Int { index }
}
