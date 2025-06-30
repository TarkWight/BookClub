//
//  QuoteEntity.swift.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import CoreData

@objc(QuoteEntity)
class QuoteEntity: NSManagedObject {}

extension QuoteEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<QuoteEntity> {
        NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
    }

    @NSManaged var id: Int64
    @NSManaged var documentId: String
    @NSManaged var text: String
    @NSManaged var bookId: Int64
}

extension QuoteEntity {
    func toDTO() -> QuoteItem {
        QuoteItem(
            id: id,
            documentId: documentId,
            text: text,
            bookId: bookId
        )
    }
}
