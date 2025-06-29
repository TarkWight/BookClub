//
//  ChapterStorageService.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import CoreData

final class ChapterStorageService: ChapterStorageServiceProtocol {

    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func makeBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }

    func fetchChapters(forDocumentId documentId: String) async throws
        -> [ChapterDTO]
    {
        let bgContext = makeBackgroundContext()
        return try await bgContext.perform {
            let req: NSFetchRequest<ChapterEntity> =
                ChapterEntity.fetchRequest()
            req.predicate = NSPredicate(
                format: "bookEntity.documentId == %d",
                documentId
            )
            req.sortDescriptors = [
                NSSortDescriptor(key: "order", ascending: true)
            ]
            let entities = try bgContext.fetch(req)
            return entities.map { $0.toDomain() }
        }
    }

    func fetchChapterSummaries(forDocumentId documentId: String) async throws
        -> [ChapterSummary]
    {
        let bgContext = makeBackgroundContext()
        return try await bgContext.perform {
            let request = NSFetchRequest<NSDictionary>(
                entityName: "ChapterEntity"
            )
            request.resultType = .dictionaryResultType
            request.predicate = NSPredicate(
                format: "bookEntity.documentId == %d",
                documentId
            )
            request.sortDescriptors = [
                NSSortDescriptor(key: "order", ascending: true)
            ]
            request.propertiesToFetch = ["id", "order", "title", "statusRaw"]

            let results = try bgContext.fetch(request)
            return results.compactMap { dict in
                guard
                    let id = dict["id"] as? Int64,
                    let orderRaw = dict["order"] as? Int32,
                    let title = dict["title"] as? String,
                    let statusRaw = dict["statusRaw"] as? Int16,
                    let status = ChapterStatus(rawValue: statusRaw)
                else { return nil }

                return ChapterSummary(
                    id: id,
                    order: Int(orderRaw),
                    title: title,
                    status: status
                )
            }
        }
    }

    func setStatus(
        chapterOrder: Int,
        inBook documentId: String,
        to newStatus: ChapterStatus
    ) async throws {
        let bgContext = makeBackgroundContext()
        try await bgContext.perform {
            let req: NSFetchRequest<ChapterEntity> =
                ChapterEntity.fetchRequest()
            req.predicate = NSPredicate(
                format: "bookEntity.documentId == %@ AND order == %d",
                documentId,
                chapterOrder
            )
            if let entity = try bgContext.fetch(req).first {
                entity.status = newStatus
                try bgContext.save()
            }
        }
    }

    func markAllPreviousAndCurrentCompleted(
        upTo order: Int,
        inBook documentId: String
    ) async throws {
        let bgContext = makeBackgroundContext()
        try await bgContext.perform {
            let req: NSFetchRequest<ChapterEntity> =
                ChapterEntity.fetchRequest()
            req.predicate = NSPredicate(
                format: "bookEntity.documentId == %@ AND order <= %d",
                documentId,
                order
            )
            let entities = try bgContext.fetch(req)
            entities.forEach { $0.status = .completed }
            try bgContext.save()
        }
    }

    func markAllFromAndAfterNotStarted(
        from order: Int,
        inBook documentId: String
    ) async throws {
        let bgContext = makeBackgroundContext()
        try await bgContext.perform {
            let req: NSFetchRequest<ChapterEntity> =
                ChapterEntity.fetchRequest()
            req.predicate = NSPredicate(
                format: "bookEntity.documentId == %@ AND order >= %d",
                documentId,
                order
            )
            let entities = try bgContext.fetch(req)
            entities.forEach { $0.status = .notStarted }
            try bgContext.save()
        }
    }

    func computeProgress(forBook documentId: String) async throws -> Double {
        let chapters = try await fetchChapters(forDocumentId: documentId)
        guard !chapters.isEmpty else { return 0 }
        let completed = chapters.filter { $0.status == .completed }.count
        return Double(completed) / Double(chapters.count)
    }

    func saveFullChapters(
        _ chapters: [ChapterDTO],
        forDocumentId documentId: String
    ) async throws {
        let context = makeBackgroundContext()

        try await context.perform {
            let bookReq: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
            bookReq.predicate = NSPredicate(
                format: "documentId == %@",
                documentId
            )

            guard let book = try context.fetch(bookReq).first else {
                throw NSError(domain: "Book not found in CoreData", code: 0)
            }

            for old in book.chapterList {
                context.delete(old)
            }

            book.removeAllChapters()

            for dto in chapters {
                let entity = ChapterEntity(context: context)
                entity.id = dto.id
                entity.documentId = dto.documentId
                entity.order = Int32(dto.order)
                entity.title = dto.title
                entity.text = dto.text
                entity.statusRaw = ChapterStatus.notStarted.rawValue

                entity.bookEntity = book
                book.addToChapters(entity)
            }
            do {
                try context.save()
            } catch let error as NSError {
                throw error
            }
        }
    }
}
