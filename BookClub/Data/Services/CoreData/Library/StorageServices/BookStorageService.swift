//
//  BookStorageService.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import CoreData

actor BookStorageService: BookStorageServiceProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func save(_ books: [Book]) async throws {
        try await container.performBackgroundTask { context in
            for book in books {
                let req = BookEntity.fetchRequest()
                req.predicate = NSPredicate(format: "id == %d", book.id)
                let entity =
                    (try context.fetch(req)).first
                    ?? BookEntity(context: context)
                entity.update(from: book)
            }
            if context.hasChanges {
                try context.save()
            }
        }
    }

    func fetch(isNew: Bool? = nil) async throws -> [Book] {
        try await container.viewContext.perform {
            let req = BookEntity.fetchRequest()
            if let flag = isNew {
                req.predicate = NSPredicate(
                    format: "isNew == %@",
                    NSNumber(value: flag)
                )
            }
            let entities = try req.execute()
            return entities.map { $0.toDomain() }
        }
    }

    func fetch(byID id: Int64) async throws -> Book? {
        try await container.viewContext.perform {
            let req = BookEntity.fetchRequest()
            req.predicate = NSPredicate(format: "id == %d", id)
            req.fetchLimit = 1
            return try req.execute().first?.toDomain()
        }
    }

    func fetch(byDocumentId documentId: String) async throws -> Book? {
        try await container.viewContext.perform {
            let req = BookEntity.fetchRequest()
            req.predicate = NSPredicate(format: "documentId == %@", documentId)
            req.fetchLimit = 1
            return try req.execute().first?.toDomain()
        }
    }

    func deleteAll() async throws {
        try await container.performBackgroundTask { context in
            let fetch: NSFetchRequest<NSFetchRequestResult> =
                BookEntity.fetchRequest()
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            try context.execute(delete)
            try context.save()
        }
    }
}
