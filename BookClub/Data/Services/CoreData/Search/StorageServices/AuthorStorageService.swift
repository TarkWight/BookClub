//
//  AuthorStorageService.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import CoreData

actor AuthorStorageService: AuthorStorageServiceProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func save(_ items: [AuthorItem]) async throws {
        try await container.performBackgroundTask { ctx in
            for author in items {
                let req = AuthorEntity.fetchRequest()
                req.predicate = NSPredicate(format: "id == %d", author.id)
                let ent =
                    (try ctx.fetch(req)).first ?? AuthorEntity(context: ctx)
                ent.id = author.id
                ent.documentId = author.documentId
                ent.name = author.name
                ent.imageUrl = author.imageUrl
            }
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func fetchAll() async throws -> [AuthorItem] {
        try await container.viewContext.perform {
            let ents = try AuthorEntity.fetchRequest().execute()
            return ents.map {
                AuthorItem(
                    id: $0.id,
                    documentId: $0.documentId,
                    name: $0.name,
                    imageUrl: $0.imageUrl
                )
            }
        }
    }

    func deleteAll() async throws {
        try await container.performBackgroundTask { ctx in
            let req = NSBatchDeleteRequest(
                fetchRequest: AuthorEntity.fetchRequest()
            )
            try ctx.execute(req)
            try ctx.save()
        }
    }
}
