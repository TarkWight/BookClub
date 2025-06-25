//
//  GenreStorageService.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import CoreData

actor GenreStorageService: GenreStorageServiceProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func save(_ items: [GenreItem]) async throws {
        try await container.performBackgroundTask { ctx in
            for genre in items {
                let req = GenreEntity.fetchRequest()
                req.predicate = NSPredicate(format: "id == %d", genre.id)
                let ent =
                    (try ctx.fetch(req)).first ?? GenreEntity(context: ctx)
                ent.id = genre.id
                ent.documentId = genre.documentId
                ent.name = genre.name
            }
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func fetchAll() async throws -> [GenreItem] {
        try await container.viewContext.perform {
            let ents = try GenreEntity.fetchRequest().execute()
            return ents.map {
                GenreItem(id: $0.id, documentId: $0.documentId, name: $0.name)
            }
        }
    }

    func deleteAll() async throws {
        try await container.performBackgroundTask { ctx in
            let req = NSBatchDeleteRequest(
                fetchRequest: GenreEntity.fetchRequest()
            )
            try ctx.execute(req)
            try ctx.save()
        }
    }
}
