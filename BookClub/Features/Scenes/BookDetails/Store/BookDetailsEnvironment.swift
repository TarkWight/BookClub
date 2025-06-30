//
//  BookDetailsEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct BookDetailsEnvironment {
    let chapterStorage: ChapterStorageServiceProtocol
    let readingSession: ReadingSessionProtocol
    let networkClient: NetworkClientProtocol
}
