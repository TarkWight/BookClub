//
//  ReadingSessionTests.swift
//  BookClubTests
//
//  Created by Tark Wight on 30.06.2025.
//

import Combine
import XCTest

@testable import BookClub

// MARK: — Заглушки для зависимостей

private final class StubChapterStorageForReading: ChapterStorageServiceProtocol
{
    let summaries: [ChapterSummary]
    init(summaries: [ChapterSummary]) { self.summaries = summaries }
    func fetchChapterSummaries(forDocumentId documentId: String) async throws
        -> [ChapterSummary]
    {
        summaries
    }
    // остальные методы не используются
    func fetchChapters(forDocumentId: String) async throws -> [ChapterDTO] {
        []
    }
    func setStatus(chapterOrder: Int, inBook: String, to: ChapterStatus)
        async throws
    {}
    func markAllPreviousAndCurrentCompleted(upTo: Int, inBook: String)
        async throws
    {}
    func markAllFromAndAfterNotStarted(from: Int, inBook: String) async throws {
    }
    func computeProgress(forBook: String) async throws -> Double { 0 }
    func saveFullChapters(_ chapters: [ChapterDTO], forDocumentId: String)
        async throws
    {}
    func isBookCached(documentId: String) async throws -> Bool { false }
}

private final class StubChunkManager: TextChunkManagerProtocol {
    private(set) var currentIndex = 0
    let chunks: [TextChunk]

    init(chunks: [TextChunk]) { self.chunks = chunks }

    func resetToChapter(
        documentId: String,
        chapterOrder: Int,
        charCountPerChunk: Int
    ) async throws {
        currentIndex = 0
    }
    func loadInitialChunk() async throws -> TextChunk {
        currentIndex = 0
        return chunks[0]
    }
    func loadNextChunk() async throws -> TextChunk {
        currentIndex += 1
        return chunks[currentIndex]
    }
    func loadPreviousChunk() async throws -> TextChunk {
        currentIndex -= 1
        return chunks[currentIndex]
    }
    var currentChunkIndex: Int { currentIndex }
    var hasNext: Bool { currentIndex + 1 < chunks.count }
    var hasPrevious: Bool { currentIndex > 0 }
}

private final class StubHighlightingService: TextHighlightingServiceProtocol {
    private(set) var prepareCalls = 0
    private(set) var startCalls = 0
    private(set) var stopCalls = 0

    func prepareHighlighting(for text: String) async {
        prepareCalls += 1
    }
    func start(interval: TimeInterval, onHighlight: @escaping (Int) -> Void)
        async
    {
        startCalls += 1
    }
    func stop() async {
        stopCalls += 1
    }
}

// MARK: — Тесты ReadingSession

@MainActor
final class ReadingSessionTests: XCTestCase {
    private var storage: StubChapterStorageForReading!
    private var chunkManager: StubChunkManager!
    private var highlighting: StubHighlightingService!
    private var session: ReadingSession!

    override func setUp() {
        super.setUp()

        let summaries = [
            ChapterSummary(id: 1, order: 1, title: "One", status: .notStarted),
            ChapterSummary(id: 2, order: 2, title: "Two", status: .notStarted),
        ]
        storage = StubChapterStorageForReading(summaries: summaries)
        let textChunks = [
            TextChunk(
                id: "c1",
                documentId: "doc",
                chapterOrder: 1,
                index: 0,
                text: "A"
            ),
            TextChunk(
                id: "c2",
                documentId: "doc",
                chapterOrder: 1,
                index: 1,
                text: "B"
            ),
        ]
        chunkManager = StubChunkManager(chunks: textChunks)
        highlighting = StubHighlightingService()

        session = ReadingSession(
            chapterStorage: storage,
            chunkManager: chunkManager,
            highlightingService: highlighting,
            charCountPerChunk: 10
        )
    }

    override func tearDown() async throws {
        await session.toggleAutoScroll()
        session = nil
    }

    func testStartReadingLoadsFirstChunkAndTitle() async {
        await session.startReading(documentId: "doc", chapterOrder: 1)
        XCTAssertEqual(session.documentId, "doc")
        XCTAssertEqual(session.currentChapterOrder, 1)
        XCTAssertEqual(session.chapterTitle, "One")
        XCTAssertEqual(session.currentChunks.map(\.text), ["A"])
    }

    func testOnChunkAppearAppendsNextChunk() async {
        await session.startReading(documentId: "doc", chapterOrder: 1)
        let first = session.currentChunks[0]
        await session.onChunkAppear(first)
        XCTAssertEqual(session.currentChunks.map(\.text), ["A", "B"])
    }

    func testToggleAutoScrollStartAndStop() async {
        await session.toggleAutoScroll()
        XCTAssertFalse(session.isAutoScrolling)
        XCTAssertNil(session.highlightedSentence)

        await MainActor.run {
            session.currentChunks = [
                TextChunk(
                    id: "",
                    documentId: "",
                    chapterOrder: 1,
                    index: 0,
                    text: "T"
                )
            ]
        }
        await session.toggleAutoScroll()
        XCTAssertTrue(session.isAutoScrolling)
        XCTAssertEqual(highlighting.prepareCalls, 1)
        XCTAssertEqual(highlighting.startCalls, 1)

        await session.toggleAutoScroll()
        XCTAssertFalse(session.isAutoScrolling)
        XCTAssertEqual(highlighting.stopCalls, 1)
        XCTAssertNil(session.highlightedSentence)
    }

    func testUserDidScrollStopsAutoScroll() async {
        await MainActor.run {
            session.currentChunks = [
                TextChunk(
                    id: "",
                    documentId: "",
                    chapterOrder: 1,
                    index: 0,
                    text: "T"
                )
            ]
        }
        await session.toggleAutoScroll()
        XCTAssertTrue(session.isAutoScrolling)

        await session.userDidScroll()
        XCTAssertFalse(session.isAutoScrolling)
        XCTAssertEqual(highlighting.stopCalls, 1)
    }

    func testGoToChapterResetsAndLoads() async {
        await MainActor.run {
            session.currentChunks = [
                TextChunk(
                    id: "",
                    documentId: "",
                    chapterOrder: 1,
                    index: 0,
                    text: "T"
                )
            ]
        }
        await session.toggleAutoScroll()

        await session.goToChapter(order: 2)
        XCTAssertEqual(session.currentChapterOrder, 2)
        XCTAssertEqual(session.chapterTitle, "Two")
        XCTAssertEqual(session.currentChunks.count, 1)
        XCTAssertFalse(session.isAutoScrolling)
    }

    // MARK: — Тесты на утечки

    func testLeak_startReadingDoesNotLeak() async throws {
        weak var weakSession: ReadingSession?
        autoreleasepool {
            let local = ReadingSession(
                chapterStorage: storage,
                chunkManager: chunkManager,
                highlightingService: highlighting,
                charCountPerChunk: 5
            )
            weakSession = local
            Task {
                await local.startReading(documentId: "doc", chapterOrder: 1)
            }
        }
        try await Task.sleep(nanoseconds: 5_000_000)
        XCTAssertNil(weakSession)
    }

    func testLeak_onChunkAppearDoesNotLeak() async throws {
        await session.startReading(documentId: "doc", chapterOrder: 1)
        weak var weakSession: ReadingSession?
        autoreleasepool {
            let local = ReadingSession(
                chapterStorage: storage,
                chunkManager: chunkManager,
                highlightingService: highlighting,
                charCountPerChunk: 5
            )
            weakSession = local
            let chunk = session.currentChunks[0]
            Task { await local.onChunkAppear(chunk) }
        }
        try await Task.sleep(nanoseconds: 5_000_000)
        XCTAssertNil(weakSession)
    }

    func testLeak_toggleAutoScrollDoesNotLeak() async throws {
        await MainActor.run {
            session.currentChunks = [
                TextChunk(
                    id: "",
                    documentId: "",
                    chapterOrder: 1,
                    index: 0,
                    text: "T"
                )
            ]
        }
        weak var weakSession: ReadingSession?
        autoreleasepool {
            let local = ReadingSession(
                chapterStorage: storage,
                chunkManager: chunkManager,
                highlightingService: highlighting,
                charCountPerChunk: 5
            )
            weakSession = local
            Task { await local.toggleAutoScroll() }
        }
        try await Task.sleep(nanoseconds: 5_000_000)
        XCTAssertNil(weakSession)
    }

    func testLeak_userDidScrollDoesNotLeak() async throws {
        weak var weakSession: ReadingSession?
        autoreleasepool {
            let local = ReadingSession(
                chapterStorage: storage,
                chunkManager: chunkManager,
                highlightingService: highlighting,
                charCountPerChunk: 5
            )
            weakSession = local
            Task { await local.userDidScroll() }
        }
        try await Task.sleep(nanoseconds: 5_000_000)
        XCTAssertNil(weakSession)
    }

    func testLeak_goToChapterDoesNotLeak() async throws {
        weak var weakSession: ReadingSession?
        autoreleasepool {
            let local = ReadingSession(
                chapterStorage: storage,
                chunkManager: chunkManager,
                highlightingService: highlighting,
                charCountPerChunk: 5
            )
            weakSession = local
            Task { await local.goToChapter(order: 1) }
        }
        try await Task.sleep(nanoseconds: 5_000_000)
        XCTAssertNil(weakSession)
    }
}
