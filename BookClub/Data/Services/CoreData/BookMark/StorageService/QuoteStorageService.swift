//
//  QuoteStorageService.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import CoreData

actor QuoteStorageService: QuoteStorageServiceProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    private func makeContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }

    func fetchQuotes(forBookId bookId: Int64? = nil) async throws
        -> [QuoteEntity]
    {
        let ctx = container.viewContext
        return try await ctx.perform {
            let req: NSFetchRequest<QuoteEntity> = QuoteEntity.fetchRequest()
            if let bid = bookId {
                req.predicate = NSPredicate(format: "book.id == %d", bid)
            }
            req.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            return try ctx.fetch(req)
        }
    }

    func save(quotes: [QuoteItem]) async throws {
        let ctx = makeContext()
        try await ctx.perform {
            for dto in quotes {
                let req: NSFetchRequest<QuoteEntity> =
                    QuoteEntity.fetchRequest()
                req.predicate = NSPredicate(format: "id == %d", dto.id)
                req.fetchLimit = 1
                let existing = try ctx.fetch(req).first
                let entity = existing ?? QuoteEntity(context: ctx)
                entity.id = dto.id
                entity.documentId = dto.documentId
                entity.text = dto.text

                let bookReq: NSFetchRequest<BookEntity> =
                    BookEntity.fetchRequest()
                bookReq.predicate = NSPredicate(format: "id == %d", dto.bookId)
                bookReq.fetchLimit = 1
                if let bookId = try ctx.fetch(bookReq).first?.id {
                    entity.bookId = bookId
                }
            }
            if ctx.hasChanges {
                try ctx.save()
            }
        }
    }

    func deleteQuote(id: Int64) async throws {
        let ctx = makeContext()
        try await ctx.perform {
            let req: NSFetchRequest<QuoteEntity> = QuoteEntity.fetchRequest()
            req.predicate = NSPredicate(format: "id == %d", id)
            let toDelete = try ctx.fetch(req)
            for obj in toDelete {
                ctx.delete(obj)
            }
            if ctx.hasChanges {
                try ctx.save()
            }
        }
    }

    func deleteAllQuotes(forBookId bookId: Int64? = nil) async throws {
        let ctx = makeContext()
        try await ctx.perform { [self] in
            let fetch: NSFetchRequest<NSFetchRequestResult> =
                QuoteEntity.fetchRequest()
            if let bid = bookId {
                fetch.predicate = NSPredicate(format: "book.id == %d", bid)
            }
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            delete.resultType = .resultTypeObjectIDs
            let result = try ctx.execute(delete) as? NSBatchDeleteResult
            if let ids = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: changes,
                    into: [container.viewContext]
                )
            }
        }
    }
}
