//
//  ChapterProgressServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 23.03.2025.
//

import Foundation

protocol ChapterProgressServiceProtocol {
    func allChaptersWithStatus() -> [BookChapter]
}
