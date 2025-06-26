//
//  AuthorEntity.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import CoreData

@objc(AuthorEntity)
class AuthorEntity: NSManagedObject {}

extension AuthorEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<AuthorEntity> {
        NSFetchRequest<AuthorEntity>(entityName: "AuthorEntity")
    }

    @NSManaged var id: Int64
    @NSManaged var documentId: String
    @NSManaged var name: String
    @NSManaged var imageUrl: String?
}
