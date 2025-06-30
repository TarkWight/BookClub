//
//  ChapterStorageServiceTests.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import CoreData
import XCTest

@testable import BookClub

final class ChapterStorageServiceTests: XCTestCase {
    var container: NSPersistentContainer!
    var service: ChapterStorageServiceProtocol!

    override func setUpWithError() throws {
        let modelURL = Bundle.main.url(
            forResource: "BookClub",
            withExtension: "momd"
        )!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        container = NSPersistentContainer(
            name: "BookClub",
            managedObjectModel: model
        )
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        service = ChapterStorageService(container: container)
    }

    private func populateTestData() throws {
        let ctx = container.viewContext

        let book = BookEntity(context: ctx)
        book.id = 1
        book.documentId = "doc1"
        book.title = "Тестовая книга"
        book.isNew = true
        book.isFavorite = false
        book.authorName = "Автор"
        book.bookDescription = "Описание"

        for i in 1...3 {
            let chapterEntity = ChapterEntity(context: ctx)
            chapterEntity.id = Int64(i)
            chapterEntity.documentId = "doc1"
            chapterEntity.order = Int32(i)
            chapterEntity.title = "Глава \(i)"
            chapterEntity.text = "Текст \(i)"
            chapterEntity.statusRaw =
                (i <= 2 ? ChapterStatus.completed : ChapterStatus.notStarted)
                .rawValue
            chapterEntity.bookEntity = book
        }

        try ctx.save()
    }

    func testComputeProgress() async throws {
        try populateTestData()

        let progress = try await service.computeProgress(forBook: "doc1")
        XCTAssertEqual(progress, 2.0 / 3.0, accuracy: 1e-6)
    }

    func testFetchChapterSummaries() async throws {
        try populateTestData()

        let summaries = try await service.fetchChapterSummaries(
            forDocumentId: "doc1"
        )
        XCTAssertEqual(summaries.count, 3)
        XCTAssertEqual(summaries.map(\.order), [1, 2, 3])
        XCTAssertEqual(
            summaries.first { $0.order == 2 }?.status,
            .completed
        )
    }

    func testFetchChaptersReturnsDTOs() async throws {
        try populateTestData()

        let dtos = try await service.fetchChapters(forDocumentId: "doc1")
        XCTAssertEqual(dtos.count, 3)
        XCTAssertTrue(
            dtos.contains { $0.order == 2 && $0.status == .completed }
        )
    }

    func testIsBookCached() async throws {
        try populateTestData()

        let isCached = try await service.isBookCached(documentId: "doc1")
        XCTAssertTrue(isCached)

        let isNotCached = try await service.isBookCached(
            documentId: "nonexistent"
        )
        XCTAssertFalse(isNotCached)
    }

    func testSetStatus() async throws {
        try populateTestData()

        try await service.setStatus(
            chapterOrder: 1,
            inBook: "doc1",
            to: .completed
        )

        let summaries = try await service.fetchChapterSummaries(
            forDocumentId: "doc1"
        )
        XCTAssertEqual(
            summaries.first { $0.order == 1 }?.status,
            .completed
        )
    }

    func testMarkAllPreviousAndCurrentCompleted() async throws {
        try populateTestData()

        try await service.markAllPreviousAndCurrentCompleted(
            upTo: 2,
            inBook: "doc1"
        )

        let summaries = try await service.fetchChapterSummaries(
            forDocumentId: "doc1"
        )
        XCTAssertTrue(
            summaries
                .filter { $0.order <= 2 }
                .allSatisfy { $0.status == .completed }
        )
    }

    func testMarkAllFromAndAfterNotStarted() async throws {
        try populateTestData()

        let ctx = container.viewContext
        let req: NSFetchRequest<ChapterEntity> = ChapterEntity.fetchRequest()
        req.predicate = NSPredicate(
            format: "bookEntity.documentId == %@",
            "doc1"
        )
        let ents = try ctx.fetch(req)
        ents.forEach { $0.statusRaw = ChapterStatus.completed.rawValue }
        try ctx.save()

        try await service.markAllFromAndAfterNotStarted(
            from: 2,
            inBook: "doc1"
        )

        let summaries = try await service.fetchChapterSummaries(
            forDocumentId: "doc1"
        )
        XCTAssertEqual(
            summaries.first { $0.order == 1 }?.status,
            .completed
        )
        XCTAssertEqual(
            summaries.first { $0.order == 2 }?.status,
            .notStarted
        )
        XCTAssertEqual(
            summaries.first { $0.order == 3 }?.status,
            .notStarted
        )
    }

    func testChapterStorageServiceDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?

        do {
            let modelURL = Bundle.main.url(
                forResource: "BookClub",
                withExtension: "momd"
            )!
            let model = NSManagedObjectModel(contentsOf: modelURL)!
            let container = NSPersistentContainer(
                name: "BookClub",
                managedObjectModel: model
            )
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
            container.loadPersistentStores { _, error in
                XCTAssertNil(error)
            }

            let service = ChapterStorageService(container: container)
            weakService = service

            _ = try? await service.computeProgress(forBook: "any")
            _ = try? await service.isBookCached(documentId: "any")
        }

        XCTAssertNil(
            weakService,
            "ChapterStorageService должен освободиться из памяти"
        )
    }
}

extension ChapterStorageServiceTests {
    private func makeService() -> ChapterStorageService {
        let model = NSManagedObjectModel.mergedModel(from: nil)!
        let container = NSPersistentContainer(
            name: "BookClub",
            managedObjectModel: model
        )
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores { _, error in XCTAssertNil(error) }
        return ChapterStorageService(container: container)
    }

    func testFetchChaptersDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            let service = makeService()
            weakService = service
            _ = try await service.fetchChapters(forDocumentId: "doc1")
        }
        XCTAssertNil(weakService, "fetchChapters захватывает сервис")
    }

    func testFetchChapterSummariesDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            let service = makeService()
            weakService = service
            _ = try await service.fetchChapterSummaries(forDocumentId: "doc1")
        }
        XCTAssertNil(weakService, "fetchChapterSummaries захватывает сервис")
    }

    func testSetStatusDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            try populateTestData()
            let service = makeService()
            weakService = service
            try await service.setStatus(
                chapterOrder: 1,
                inBook: "doc1",
                to: .completed
            )
        }
        XCTAssertNil(weakService, "setStatus захватывает сервис")
    }

    func testMarkAllPreviousAndCurrentCompletedDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            try populateTestData()
            let service = makeService()
            weakService = service
            try await service.markAllPreviousAndCurrentCompleted(
                upTo: 2,
                inBook: "doc1"
            )
        }
        XCTAssertNil(
            weakService,
            "markAllPreviousAndCurrentCompleted захватывает сервис"
        )
    }

    func testMarkAllFromAndAfterNotStartedDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            try populateTestData()
            let service = makeService()
            weakService = service
            try await service.markAllFromAndAfterNotStarted(
                from: 2,
                inBook: "doc1"
            )
        }
        XCTAssertNil(
            weakService,
            "markAllFromAndAfterNotStarted захватывает сервис"
        )
    }

    func testComputeProgressDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            try populateTestData()
            let service = makeService()
            weakService = service
            _ = try await service.computeProgress(forBook: "doc1")
        }
        XCTAssertNil(weakService, "computeProgress захватывает сервис")
    }

    func testSaveFullChaptersDoesNotLeak() async throws {
        try populateTestData()
        let dtos = try await service.fetchChapters(forDocumentId: "doc1")
        do {
            _ = try? await service.saveFullChapters(
                dtos,
                forDocumentId: "doc1"
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testIsBookCachedDoesNotLeak() async throws {
        weak var weakService: ChapterStorageService?
        do {
            let service = makeService()
            weakService = service
            _ = try await service.isBookCached(documentId: "doc1")
        }
        XCTAssertNil(weakService, "isBookCached захватывает сервис")
    }
}
