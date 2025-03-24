//
//  TextChunkManager.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import SwiftUI

final class TextChunkManager: ObservableObject, TextChunkManagerProtocol{
    // MARK: - Properties
    
    private let chunkSize: Int
    private let cacheDirectory: URL
    private let chaptersFileName = "chapters.json"
    
    private var cache: [Int: TextChunk] = [:]
    private var chapters: [BookChapter] = []
    
    @Published private(set) var currentChunkIndexValue = 0
    @Published private(set) var currentChunks: [TextChunk] = []
    
    // MARK: - Init
    
    init(chunkSize: Int = 2000) {
        self.chunkSize = chunkSize
        
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.cacheDirectory = documents.appendingPathComponent("BookChunks", isDirectory: true)
        } else {
            fatalError("Unable to find documents directory")
        }
        
        setup()
    }
    
    private func setup() {
        createDirectoryIfNeeded()
        loadChaptersFromDisk()
    }
    
    // MARK: - Public API
    
    func loadInitialChunk() throws -> TextChunk {
        currentChunkIndexValue = chapters.first?.chunkIndex ?? 0
        try  preloadChunks(from: currentChunkIndexValue)
        return try requireChunk(at: currentChunkIndexValue)
    }
    
    func loadNextChunk()  throws -> TextChunk {
        let nextIndex = currentChunkIndexValue + 1
        guard nextIndex < totalChunks() else {
            throw ChunkLoaderError.chunkNotFound(nextIndex)
        }
        currentChunkIndexValue = nextIndex
        try  preloadChunks(from: currentChunkIndexValue)
        return try requireChunk(at: currentChunkIndexValue)
    }
    
    func loadPreviousChunk()  throws -> TextChunk {
        let previousIndex = currentChunkIndexValue - 1
        guard previousIndex >= 0 else {
            throw ChunkLoaderError.chunkNotFound(previousIndex)
        }
        currentChunkIndexValue = previousIndex
        try  preloadChunks(from: currentChunkIndexValue)
        return try requireChunk(at: currentChunkIndexValue)
    }
    
    func loadChunk(for chapter: BookChapter)  throws -> TextChunk {
        currentChunkIndexValue = chapter.chunkIndex
        try  preloadChunks(from: currentChunkIndexValue)
        return try requireChunk(at: currentChunkIndexValue)
    }
    
    func currentChapterTitle() -> String? {
        chapters.last(where: { $0.chunkIndex <= currentChunkIndexValue })?.title
    }
    
    func fetchChapters() -> [BookChapter] {
        chapters
    }
    
    func allChaptersWithStatus() -> [BookChapter] {
        chapters
    }
    
    func totalChunks() -> Int {
        let files = (try? FileManager.default.contentsOfDirectory(atPath: cacheDirectory.path)) ?? []
        return files.filter { $0.hasPrefix("chunk_") && $0.hasSuffix(".txt") }.count
    }
    
    func hasPrevious()  -> Bool {
        currentChunkIndexValue > 0
    }
    
    func hasNext()  -> Bool {
        let total = totalChunks()
        return currentChunkIndexValue + 1 < total
    }
    
    func getCurrentChunkIndex() -> Int {
        currentChunkIndexValue
    }
    
    func setCurrentChunkIndex(_ index: Int) {
        self.currentChunkIndexValue = index
    }
    
    // MARK: - Private Helpers
    
    private func loadChunk(at index: Int)  throws -> TextChunk {
        let fileURL = cacheDirectory.appendingPathComponent("chunk_\(index).txt")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw NSError(domain: "Chunk not found", code: 404, userInfo: nil)
        }
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return TextChunk(index: index, text: content)
    }
    
    private func preloadChunks(from index: Int)  throws {
        let total = totalChunks()
        let indices = [index - 1, index, index + 1, index + 2].filter { $0 >= 0 && $0 < total }
        
        let toRemove = cache.keys.filter { !indices.contains($0) }
        for i in toRemove {
            cache.removeValue(forKey: i)
        }
        
        for i in indices where cache[i] == nil {
            let chunk = try  loadChunk(at: i)
            cache[i] = chunk
        }
    }
    
    private func requireChunk(at index: Int) throws -> TextChunk {
        guard let chunk = cache[index] else {
            throw ChunkLoaderError.chunkNotFound(index)
        }
        return chunk
    }
    
    private func loadChaptersFromDisk() {
        let fileURL = cacheDirectory.appendingPathComponent(chaptersFileName)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([BookChapter].self, from: data) else {
            self.chapters = []
            return
        }
        self.chapters = decoded
    }
    
    private func createDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
}
