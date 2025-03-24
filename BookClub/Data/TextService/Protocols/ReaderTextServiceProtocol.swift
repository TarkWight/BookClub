//
//  ReaderTextServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 23.03.2025.
//

import Foundation

protocol ReaderTextServiceProtocol {
    func loadInitialChunk() throws -> TextChunk
    func loadNextChunk() throws -> TextChunk
    func loadPreviousChunk() throws -> TextChunk
    func loadChunk(for chapter: BookChapter) throws -> TextChunk

    func currentChapterTitle() -> String?

    func getCurrentChunkIndex() -> Int
    func setCurrentChunkIndex(_ index: Int)

    func hasNext() -> Bool
    func hasPrevious() -> Bool
}
