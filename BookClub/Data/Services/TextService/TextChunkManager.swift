//
//  TextChunkManager.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import Foundation

final class TextChunkManager: TextChunkManagerProtocol, @unchecked Sendable {
    private let chapterStorage: ChapterStorageServiceProtocol
    private let cache = NSCache<NSString, ChunkBox>()

    private class ChunkBox: NSObject {
        let chunk: TextChunk

        init(_ chunk: TextChunk) {
            self.chunk = chunk
        }

    }

    private var documentId: String = ""
    private var chapterOrder: Int = 0
    private var charCount: Int = 0
    private var fullText: String = ""
    private var totalChunks: Int = 0

    private(set) var currentChunkIndex: Int = 0

    var hasNext: Bool { currentChunkIndex + 1 < totalChunks }
    var hasPrevious: Bool { currentChunkIndex > 0 }

    init(chapterStorage: ChapterStorageServiceProtocol) {
        self.chapterStorage = chapterStorage
        cache.countLimit = 50
    }

    func resetToChapter(
        documentId: String,
        chapterOrder: Int,
        charCountPerChunk: Int
    ) async throws {
        self.documentId = documentId
        self.chapterOrder = chapterOrder
        self.charCount = charCountPerChunk
        self.currentChunkIndex = 0

        // TODO: - Вспомнить, зачем он здесь
        //        _ = try await chapterStorage.fetchChapterSummaries(
        //            forDocumentId: documentId
        //        )

        let fullDTO = try await chapterStorage.fetchChapters(
            forDocumentId: documentId
        )
        let dto = fullDTO.first { $0.order == chapterOrder }

        self.fullText = dto?.text ?? ""
        self.totalChunks = Int(ceil(Double(fullText.count) / Double(charCount)))
        cache.removeAllObjects()
    }

    func loadInitialChunk() async throws -> TextChunk {
        try await makeChunk(at: 0)
    }

    func loadNextChunk() async throws -> TextChunk {
        let next = currentChunkIndex + 1
        guard next < totalChunks else {
            throw ChunkLoaderError.chunkNotFound(next)
        }
        return try await makeChunk(at: next)
    }

    func loadPreviousChunk() async throws -> TextChunk {
        let prev = currentChunkIndex - 1
        guard prev >= 0 else {
            throw ChunkLoaderError.chunkNotFound(prev)
        }
        return try await makeChunk(at: prev)
    }

    // MARK: — Private methods

    private func makeChunk(at index: Int) async throws -> TextChunk {
        let key = "b\(documentId)_c\(chapterOrder)_i\(index)" as NSString

        if let box = cache.object(forKey: key) {
            let chunk = box.chunk
            currentChunkIndex = index
            preloadNeighbors(around: index)
            return chunk
        }

        let start = index * charCount
        guard start < fullText.count else {
            throw ChunkLoaderError.chunkNotFound(index)
        }
        let end = min(fullText.count, start + charCount)
        let slice = String(
            fullText
                .dropFirst(start)
                .prefix(end - start)
        )

        let chunk = TextChunk(
            id: key as String,
            documentId: documentId,
            chapterOrder: chapterOrder,
            index: index,
            text: slice
        )

        cache.setObject(ChunkBox(chunk), forKey: key)
        currentChunkIndex = index
        preloadNeighbors(around: index)
        return chunk
    }

    private func preloadNeighbors(around index: Int) {
        for i in [index - 1, index + 1] {
            guard i >= 0, i < totalChunks else { continue }
            Task { _ = try? await makeChunk(at: i) }
        }
    }
}
