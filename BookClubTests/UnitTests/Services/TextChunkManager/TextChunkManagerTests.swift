//
//  TextChunkManagerTests.swift
//  BookClubTests
//
//  Created by Tark Wight on 30.06.2025.
//

import XCTest
import Foundation
@testable import BookClub

// MARK: — Stub для ChapterStorageServiceProtocol

private final class StubChapterStorage: ChapterStorageServiceProtocol {
    let chapters: [ChapterDTO]

    init(chapters: [ChapterDTO]) {
        self.chapters = chapters
    }

    func fetchChapters(forDocumentId documentId: String) async throws -> [ChapterDTO] {
        chapters
    }
    func fetchChapterSummaries(forDocumentId documentId: String) async throws -> [ChapterSummary] {
        fatalError("не используется в этих тестах")
    }
    func setStatus(chapterOrder: Int, inBook documentId: String, to newStatus: ChapterStatus) async throws {}
    func markAllPreviousAndCurrentCompleted(upTo order: Int, inBook documentId: String) async throws {}
    func markAllFromAndAfterNotStarted(from order: Int, inBook documentId: String) async throws {}
    func computeProgress(forBook documentId: String) async throws -> Double { 0 }
    func saveFullChapters(_ chapters: [ChapterDTO], forDocumentId documentId: String) async throws {}
    func isBookCached(documentId: String) async throws -> Bool { false }
}

// MARK: — Тесты TextChunkManager

final class TextChunkManagerTests: XCTestCase {
    // длинный текст 10 символов → при charCount=4 → 3 чанка
    let longText = "abcdefghij"
    fileprivate var storage: StubChapterStorage!
    fileprivate var manager: TextChunkManager!

    override func setUp() {
        super.setUp()
        let dto = ChapterDTO(
            id: 1,
            documentId: "doc",
            order: 1,
            title: "T",
            text: longText,
            status: .notStarted
        )
        storage = StubChapterStorage(chapters: [dto])
        manager = TextChunkManager(chapterStorage: storage)
    }

    // MARK: — Функционал

    func testResetAndInitialChunk() async throws {
        try await manager.resetToChapter(
            documentId: "doc",
            chapterOrder: 1,
            charCountPerChunk: 4
        )
        let chunk = try await manager.loadInitialChunk()
        XCTAssertEqual(chunk.text, "abcd")
        XCTAssertEqual(manager.currentChunkIndex, 0)
        XCTAssertTrue(manager.hasNext)
        XCTAssertFalse(manager.hasPrevious)
    }

    func testLoadNextAndPreviousChunks() async throws {
        try await manager.resetToChapter(documentId: "doc", chapterOrder: 1, charCountPerChunk: 4)

        let next = try await manager.loadNextChunk()
        XCTAssertEqual(next.text, "efgh")
        XCTAssertEqual(manager.currentChunkIndex, 1)
        XCTAssertTrue(manager.hasNext)
        XCTAssertTrue(manager.hasPrevious)

        let last = try await manager.loadNextChunk()
        XCTAssertEqual(last.text, "ij")
        XCTAssertEqual(manager.currentChunkIndex, 2)
        XCTAssertFalse(manager.hasNext)
        XCTAssertTrue(manager.hasPrevious)

        let prev = try await manager.loadPreviousChunk()
        XCTAssertEqual(prev.text, "efgh")
        XCTAssertEqual(manager.currentChunkIndex, 1)
    }

    func testLoadNextOutOfBoundsThrows() async throws {
        try await manager.resetToChapter(
            documentId: "doc",
            chapterOrder: 1,
            charCountPerChunk: 10
        )
        let mgr = manager!
        await XCTAssertThrowsErrorAsync {
            _ = try await mgr.loadNextChunk()
        }
    }

    func testLoadPreviousOutOfBoundsThrows() async throws {
        try await manager.resetToChapter(
            documentId: "doc",
            chapterOrder: 1,
            charCountPerChunk: 10
        )
        let mgr = manager!
        await XCTAssertThrowsErrorAsync {
            _ = try await mgr.loadPreviousChunk()
        }
    }
    // MARK: — Утечки памяти

    private func autoreleaseAndAwait(
        action: @escaping (TextChunkManager) async throws -> Void
    ) -> TextChunkManager? {
        weak var weakMgr: TextChunkManager?
        autoreleasepool {
            let mgr = TextChunkManager(chapterStorage: storage)
            weakMgr = mgr
            let exp = expectation(description: "async")
            Task {
                try? await action(mgr)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 1)
        }
        return weakMgr
    }

    func testLeak_resetToChapter() {
        let weakMgr = autoreleaseAndAwait { mgr in
            try await mgr.resetToChapter(documentId: "doc", chapterOrder: 1, charCountPerChunk: 4)
        }
        XCTAssertNil(weakMgr, "resetToChapter должен деаллоцировать менеджер")
    }

    func testLeak_loadInitialChunk() {
        let weakMgr = autoreleaseAndAwait { mgr in
            try await mgr.resetToChapter(documentId: "doc", chapterOrder: 1, charCountPerChunk: 4)
            _ = try await mgr.loadInitialChunk()
        }
        XCTAssertNil(weakMgr, "loadInitialChunk должен деаллоцировать менеджер")
    }

    func testLeak_loadNextChunk() {
        let weakMgr = autoreleaseAndAwait { mgr in
            try await mgr.resetToChapter(documentId: "doc", chapterOrder: 1, charCountPerChunk: 4)
            _ = try await mgr.loadNextChunk()
        }
        XCTAssertNil(weakMgr, "loadNextChunk должен деаллоцировать менеджер")
    }

    func testLeak_loadPreviousChunk() {
        let weakMgr = autoreleaseAndAwait { mgr in
            try await mgr.resetToChapter(documentId: "doc", chapterOrder: 1, charCountPerChunk: 4)
            _ = try await mgr.loadNextChunk()
            _ = try await mgr.loadPreviousChunk()
        }
        XCTAssertNil(weakMgr, "loadPreviousChunk должен деаллоцировать менеджер")
    }
}

// MARK: — Асинхронный XCTAssertThrowsError

private func XCTAssertThrowsErrorAsync(
    file: StaticString = #file, line: UInt = #line,
    _ body: @escaping () async throws -> Void
) async {
    do {
        try await body()
        XCTFail("Ожидалась ошибка, но её не было", file: file, line: line)
    } catch {
        // всё ок
    }
}
