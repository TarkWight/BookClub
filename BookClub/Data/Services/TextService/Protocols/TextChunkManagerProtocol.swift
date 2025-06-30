//
//  TextChunkManagerProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 24.03.2025.
//

import Foundation

protocol TextChunkManagerProtocol: Sendable {

    func resetToChapter(
        documentId: String,
        chapterOrder: Int,
        charCountPerChunk: Int
    ) async throws

    func loadInitialChunk() async throws -> TextChunk

    func loadNextChunk() async throws -> TextChunk

    func loadPreviousChunk() async throws -> TextChunk

    var currentChunkIndex: Int { get }

    var hasNext: Bool { get }
    var hasPrevious: Bool { get }
}
