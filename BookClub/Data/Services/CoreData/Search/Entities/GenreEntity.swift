//
//  GenreEntity.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import CoreData

@objc(GenreEntity)
class GenreEntity: NSManagedObject {}

extension GenreEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<GenreEntity> {
        NSFetchRequest<GenreEntity>(entityName: "GenreEntity")
    }

    @NSManaged var id: Int64
    @NSManaged var documentId: String
    @NSManaged var name: String
}
