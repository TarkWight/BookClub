//
//  ChapterEntity.swift
//  BookClub
//
//  Created by Tark Wight on 27.06.2025.
//

import CoreData

@objc(ChapterEntity)
class ChapterEntity: NSManagedObject {}

extension ChapterEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ChapterEntity> {
        NSFetchRequest<ChapterEntity>(entityName: "ChapterEntity")
    }

    @NSManaged var id: Int64
    @NSManaged var documentId: String
    @NSManaged public var order: Int32
    @NSManaged public var title: String
    @NSManaged public var text: String?
    @NSManaged public var statusRaw: Int16
    @NSManaged public var bookEntity: BookEntity
}

extension ChapterEntity {
    func toDomain() -> ChapterDTO {
        ChapterDTO(
            id: id,
            documentId: documentId,
            order: Int(order),
            title: title,
            text: text,
            status: status
        )
    }
}
