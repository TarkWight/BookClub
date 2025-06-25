//
//  BookEntity.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import CoreData

@objc(BookEntity)
class BookEntity: NSManagedObject {}

extension BookEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<BookEntity> {
        NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged var id: Int64
    @NSManaged var documentId: String
    @NSManaged var title: String
    @NSManaged var coverURL: String?
    @NSManaged var illustrationURL: String?
    @NSManaged var isNew: Bool
}

extension BookEntity {
    func toDomain() -> Book {
        Book(
            id: id,
            documentId: documentId,
            title: title,
            coverURL: coverURL.flatMap(URL.init(string:)),
            illustrationURL: illustrationURL.flatMap(URL.init(string:)),
            isNew: isNew,
        )
    }
}

extension BookEntity {
    func update(from book: Book) {
        id = book.id
        documentId = book.documentId
        title = book.title
        coverURL = book.coverURL?.absoluteString
        illustrationURL = book.illustrationURL?.absoluteString
        isNew = book.isNew    }
}
