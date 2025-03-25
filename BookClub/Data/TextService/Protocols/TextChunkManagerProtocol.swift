//
//  TextChunkManagerProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 24.03.2025.
//

import Foundation

protocol TextChunkManagerProtocol:
    ReaderTextServiceProtocol,
    ChaptersListServiceProtocol,
    ChapterProgressServiceProtocol {

    func totalChunks() -> Int
}
