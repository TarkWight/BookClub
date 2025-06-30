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

        let fullDTO = try await chapterStorage.fetchChapters(
            forDocumentId: documentId
        )
        let dto = fullDTO.first { $0.order == chapterOrder }

        self.fullText = dto?.text ?? ""
        self.totalChunks = Int(ceil(Double(fullText.count) / Double(charCount)))
        cache.removeAllObjects()
    }

    func loadInitialChunk() async throws -> TextChunk {
        guard let chunk = makeChunk(at: 0) else {
            throw ChunkLoaderError.chunkNotFound(0)
        }
        currentChunkIndex = 0
        preloadNeighbors(around: 0)
        return chunk
    }

    func loadNextChunk() async throws -> TextChunk {
        let next = currentChunkIndex + 1
        guard let chunk = makeChunk(at: next) else {
            throw ChunkLoaderError.chunkNotFound(next)
        }
        currentChunkIndex = next
        preloadNeighbors(around: next)
        return chunk
    }

    func loadPreviousChunk() async throws -> TextChunk {
        let prev = currentChunkIndex - 1
        guard let chunk = makeChunk(at: prev) else {
            throw ChunkLoaderError.chunkNotFound(prev)
        }
        currentChunkIndex = prev
        preloadNeighbors(around: prev)
        return chunk
    }

    // MARK: — Private methods

    private func makeChunk(at index: Int) -> TextChunk? {
        guard index >= 0, index < totalChunks else { return nil }
        let key = cacheKey(for: index)
        if let box = cache.object(forKey: key) {
            return box.chunk
        } else {
            let start = index * charCount
            guard start < fullText.count else { return nil }
            let end = min(fullText.count, start + charCount)
            let slice = String(fullText.dropFirst(start).prefix(end - start))
            let chunk = TextChunk(
                id: key as String,
                documentId: documentId,
                chapterOrder: chapterOrder,
                index: index,
                text: slice
            )
            cache.setObject(ChunkBox(chunk), forKey: key)
            return chunk
        }
    }

    private func preloadNeighbors(around index: Int) {
        for i in [index - 1, index + 1] {
            guard i >= 0, i < totalChunks else { continue }
            let key = cacheKey(for: i)
            guard cache.object(forKey: key) == nil else { continue }

            Task { [weak self] in
                guard let self = self else { return }
                let start = i * charCount
                guard start < fullText.count else { return }
                let end = min(fullText.count, start + charCount)
                let slice = String(
                    fullText.dropFirst(start).prefix(end - start)
                )
                let chunk = TextChunk(
                    id: key as String,
                    documentId: documentId,
                    chapterOrder: chapterOrder,
                    index: i,
                    text: slice
                )
                cache.setObject(ChunkBox(chunk), forKey: key)
            }
        }
    }

    private func cacheKey(for index: Int) -> NSString {
        "b\(documentId)_c\(chapterOrder)_i\(index)" as NSString
    }
}
