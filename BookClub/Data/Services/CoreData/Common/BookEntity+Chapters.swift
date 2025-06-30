//
//  BookEntity+Chapters.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import CoreData

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
