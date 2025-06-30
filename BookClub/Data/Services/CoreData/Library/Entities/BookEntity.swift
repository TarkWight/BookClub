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
    @NSManaged var isFavorite: Bool
    @NSManaged var authorName: String?
    @NSManaged var chapters: NSSet?
    @NSManaged var bookDescription: String
}

extension BookEntity {
    func toDomain() -> Book {
        Book(
            id: id,
            documentId: documentId,
            title: title,
            coverURL: coverURL.flatMap(URL.init(string:)),
            illustrationURL: illustrationURL.flatMap(URL.init(string:)),
            isFavorite: isFavorite,
            isNew: isNew,
            authorName: authorName,
            description: bookDescription,
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
        isFavorite = book.isFavorite ?? false
        isNew = book.isNew
    }
}

extension BookEntity {
    public var chapterList: [ChapterEntity] {
        let set = chapters as? Set<ChapterEntity> ?? []
        return set.sorted { $0.order < $1.order }
    }

    @objc(addChaptersObject:)
    @NSManaged public func addToChapters(_ value: ChapterEntity)

    @objc(removeChaptersObject:)
    @NSManaged public func removeFromChapters(_ value: ChapterEntity)
}

extension BookEntity {
    func removeAllChapters() {
        guard let chapters = chapters as? Set<ChapterEntity> else { return }
        for chapter in chapters {
            removeFromChapters(chapter)
        }
    }
}
