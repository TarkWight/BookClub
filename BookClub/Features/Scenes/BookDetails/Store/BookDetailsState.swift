//
//  BookDetailsState.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct BookDetailsState: Equatable {
    var didLoadOnAppear = false

    var bookId: Int = 0
    var bookDocumentId: String = ""
    var title: String = ""
    var author: String = ""
    var description: String = ""
    var progress: Double = 0
    var chapters: [ChapterSummary] = []
    var selectedChapterOrder: Int? = nil

    var isFavorite: Bool = false
    var favoriteId: String? = nil

    var coverURL: URL?

    var bookDownload: Loadable<[ChapterDTO]> = .idle
    var isDownloaded: Bool = false

    var featureDidClose: Bool = false
}
