//
//  BookmarksEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

struct BookmarksEnvironment: Sendable {
    let networkClient: NetworkClientProtocol
    let quoteStorage: QuoteStorageServiceProtocol
    let bookStorage: BookStorageServiceProtocol
    let chapterStorage: ChapterStorageServiceProtocol
}
