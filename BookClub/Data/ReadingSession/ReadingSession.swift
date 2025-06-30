//
//  ReadingSession.swift
//  BookClub
//
//  Created by Tark Wight on 24.03.2025.
//

import SwiftUI

@MainActor
final class ReadingSession: ReadingSessionProtocol, ObservableObject {
    // MARK: - Dependencies
    private let chapterStorage: ChapterStorageServiceProtocol
    private let chunkManager: TextChunkManagerProtocol
    private let highlightingService: TextHighlightingServiceProtocol

    // MARK: - UI State
    @Published var currentChunks: [TextChunk] = []
    @Published var currentChapterOrder: Int = 0
    @Published var documentId: String = ""
    @Published var chapterTitle: String = ""
    @Published var isAutoScrolling: Bool = false
    @Published var highlightedSentence: Int? = nil

    // MARK: - Reader Settings
    @Published var fontSize: CGFloat = 16
    @Published var lineSpacing: CGFloat = 8
    private let charCountPerChunk: Int

    // MARK: - Init
    init(
        chapterStorage: ChapterStorageServiceProtocol,
        chunkManager: TextChunkManagerProtocol,
        highlightingService: TextHighlightingServiceProtocol,
        charCountPerChunk: Int
    ) {
        self.chapterStorage = chapterStorage
        self.chunkManager = chunkManager
        self.highlightingService = highlightingService
        self.charCountPerChunk = charCountPerChunk
    }

    // MARK: - Start Reading
    func startReading(
        documentId: String,
        chapterOrder: Int
    ) async {
        self.documentId = documentId
        self.currentChapterOrder = chapterOrder

        if let summary =
            try? await chapterStorage
                .fetchChapterSummaries(forDocumentId: documentId)
                .first(where: { $0.order == chapterOrder }) {
            chapterTitle = summary.title
        }

        try? await chunkManager.resetToChapter(
            documentId: documentId,
            chapterOrder: chapterOrder,
            charCountPerChunk: charCountPerChunk
        )

        if let first = try? await chunkManager.loadInitialChunk() {
            currentChunks = [first]
        }
    }

    // MARK: - Chunk Loading
    func onChunkAppear(_ chunk: TextChunk) async {
        guard chunk.index == chunkManager.currentChunkIndex,
              chunkManager.hasNext
        else { return }
        if let next = try? await chunkManager.loadNextChunk() {
            currentChunks.append(next)
        }
    }

    // MARK: - Auto Scroll
    // MARK: - Auto Scroll
    func toggleAutoScroll() async {
        if isAutoScrolling {
            await highlightingService.stop()
            isAutoScrolling = false
            highlightedSentence = nil
        } else if let chunk = currentChunks.last {
            await highlightingService.prepareHighlighting(for: chunk.text)
            isAutoScrolling = true
            // Сразу ждем старта, чтобы startCalls инкрементировался до возврата
            await highlightingService.start(interval: 2) { [weak self] idx in
                self?.highlightedSentence = idx
            }
        }
    }

    // MARK: - User Scroll
    func userDidScroll() async {
        if isAutoScrolling {
            await highlightingService.stop()
            isAutoScrolling = false
            highlightedSentence = nil
        }
    }

    // MARK: - Change Chapter
    func goToChapter(order: Int) async {
        await userDidScroll()
        await startReading(documentId: documentId, chapterOrder: order)
    }
}
