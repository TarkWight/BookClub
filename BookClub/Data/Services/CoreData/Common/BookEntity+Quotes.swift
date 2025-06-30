//
//  BookEntity+Quotes.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import CoreData

extension BookEntity {
    @objc(addQuotesObject:)
    @NSManaged public func addToQuotes(_ value: QuoteEntity)

    @objc(removeQuotesObject:)
    @NSManaged public func removeFromQuotes(_ value: QuoteEntity)

    public var quoteList: [QuoteEntity] {
        let set = quotes as? Set<QuoteEntity> ?? []
        return
            set
            .sorted { $0.id < $1.id }
    }
}
