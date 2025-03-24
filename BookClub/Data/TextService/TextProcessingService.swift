//
//  TextProcessingService.swift
//  BookClub
//
//  Created by Tark Wight on 22.03.2025.
//

import Foundation

final class TextProcessingService {
    // MARK: - Properties
    
    private let chunkSize: Int
    private let cacheDirectory: URL
    private let chaptersFileName = "chapters.json"
    
    // TODO: Подкрутить регулярку
    private let chapterKeywords = ["Глава", "Факты", "Пролог", "Предисловие", "Эпилог", "Примечания"]

    // MARK: - Init
    
    init(chunkSize: Int = 2000) {
        self.chunkSize = chunkSize
        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.cacheDirectory = documents.appendingPathComponent("BookChunks", isDirectory: true)
        } else {
            fatalError("Unable to find documents directory")
        }
        createDirectoryIfNeeded()
    }

    // MARK: - Public API

    func processRawText(from fileURL: URL) throws {
        let rawText = try loadRawText(from: fileURL)
        let paragraphs = splitIntoParagraphs(rawText)
        let chunks = splitIntoChunks(paragraphs)
        let chapters = extractChapters(from: chunks)

        try saveChunks(chunks)
        try saveChapters(chapters)
    }
    
    // MARK: - Private

    private func loadRawText(from fileURL: URL) throws -> String {
        try String(contentsOf: fileURL, encoding: .utf8)
    }

    private func splitIntoParagraphs(_ text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func splitIntoChunks(_ paragraphs: [String]) -> [TextChunk] {
        var chunks: [TextChunk] = []
        var currentText = ""
        var chunkIndex = 0

        for paragraph in paragraphs {
            if currentText.count + paragraph.count + 1 > chunkSize {
                let chunk = TextChunk(index: chunkIndex, text: currentText.trimmingCharacters(in: .whitespacesAndNewlines))
                chunks.append(chunk)
                chunkIndex += 1
                currentText = ""
            }
            currentText += paragraph + "\n"
        }

        if !currentText.isEmpty {
            let chunk = TextChunk(index: chunkIndex, text: currentText.trimmingCharacters(in: .whitespacesAndNewlines))
            chunks.append(chunk)
        }

        return chunks
    }

    private func extractChapters(from chunks: [TextChunk]) -> [BookChapter] {
        var chapters: [BookChapter] = []
        for chunk in chunks {
            for keyword in chapterKeywords {
                if chunk.text.contains(keyword) {
                    let lines = chunk.text.components(separatedBy: .newlines)
                    if let title = lines.first(where: { $0.contains(keyword) }) {
                        chapters.append(BookChapter(title: title, chunkIndex: chunk.index))
                        break
                    }
                }
            }
        }

        if chapters.isEmpty {
            chapters.append(BookChapter(title: "Начало", chunkIndex: 0))
        }

        return chapters
    }

    private func saveChunks(_ chunks: [TextChunk]) throws {
        for chunk in chunks {
            let fileURL = cacheDirectory.appendingPathComponent("chunk_\(chunk.index).txt")
            try chunk.text.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }

    private func saveChapters(_ chapters: [BookChapter]) throws {
        let chaptersURL = cacheDirectory.appendingPathComponent(chaptersFileName)
        let data = try JSONEncoder().encode(chapters)
        try data.write(to: chaptersURL, options: .atomic)
    }

    private func createDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
}
