//
//  ReadingSession.swift
//  BookClub
//
//  Created by Tark Wight on 24.03.2025.
//

import SwiftUI

@MainActor
final class ReadingSession: ObservableObject {
    // MARK: - Dependencies
    private let chunkManager: TextChunkManager

    // MARK: - UI State
    @Published var currentChunks: [TextChunk] = []
    @Published var currentChapterTitle: String = ""
    @Published var fontSize: CGFloat = 16
    @Published var lineSpacing: CGFloat = 8

    // MARK: - Internal State
    private var isLoading = false

    // MARK: - Init
    init(chunkManager: TextChunkManager) {
        self.chunkManager = chunkManager
    }

    // MARK: - Start points

    func startFromChunk(index: Int) async {
        chunkManager.setCurrentChunkIndex(index)
        await loadInitialChunkSet()
    }

    func startFromChapter(_ chapter: BookChapter) async {
        do {
            let chunk = try chunkManager.loadChunk(for: chapter)
            chunkManager.setCurrentChunkIndex(chunk.index)
            currentChunks = [chunk]
            updateChapterTitle()
        } catch {
            print("Failed to load chunk for chapter: \(error)")
        }
    }

    func startFromLastRead() async {
        let index = chunkManager.getCurrentChunkIndex()
        await startFromChunk(index: index)
    }

    // MARK: - Loading chunks when scrolling

    func onChunkAppear(_ chunk: TextChunk) {
        guard chunk.index == currentChunks.last?.index else { return }
        Task {
            await loadNextChunkIfNeeded()
        }
    }

    func loadNextChunkIfNeeded() async {
        guard !isLoading, chunkManager.hasNext() else { return }
        isLoading = true
        do {
            let chunk = try chunkManager.loadNextChunk()
            if !currentChunks.contains(where: { $0.index == chunk.index }) {
                currentChunks.append(chunk)
            }
            updateChapterTitle()
        } catch {
            print("Failed to load next chunk: \(error)")
        }
        isLoading = false
    }

    // MARK: - Chapter transitions

    func jumpToNextChapter() {
        guard let currentIndex = chapterIndex(for: chunkManager.getCurrentChunkIndex()) else { return }
        let chapters = chunkManager.fetchChapters()
        guard currentIndex + 1 < chapters.count else { return }
        Task {
            await startFromChapter(chapters[currentIndex + 1])
        }
    }

    func jumpToPreviousChapter() {
        guard let currentIndex = chapterIndex(for: chunkManager.getCurrentChunkIndex()) else { return }
        let chapters = chunkManager.fetchChapters()
        guard currentIndex - 1 >= 0 else { return }
        Task {
            await startFromChapter(chapters[currentIndex - 1])
        }
    }

    // MARK: - Current chapter

    func chapter(for index: Int) -> BookChapter? {
        chunkManager.fetchChapters().last(where: { $0.chunkIndex <= index })
    }

    private func chapterIndex(for chunkIndex: Int) -> Int? {
        chunkManager.fetchChapters().lastIndex(where: { $0.chunkIndex <= chunkIndex })
    }

    private func updateChapterTitle() {
        if let title = chunkManager.currentChapterTitle(), title != currentChapterTitle {
            currentChapterTitle = title
        }
    }

    // MARK: - Initial load

    func loadInitialChunkSet() async {
        do {
            let chunk = try chunkManager.loadInitialChunk()
            currentChunks = [chunk]
            updateChapterTitle()
        } catch {
            print("Failed to load initial chunk: \(error)")
        }
    }
    
    // MARK: - List of chapters
    
    func fetchChapters() -> [BookChapter] {
        chunkManager.fetchChapters()
    }
    
}
