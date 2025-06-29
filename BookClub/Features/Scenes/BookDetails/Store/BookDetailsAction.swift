//
//  BookDetailsAction.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

enum BookDetailsAction: Equatable {
    case configure(BookDetailsPayload)
    case onAppear
    case onDisappear

    case chaptersLoaded(Result<[ChapterSummary], NetworkError>)
    case cacheStatusLoaded(Bool)

    case progressLoaded(Result<Double, NetworkError>)
    case favoriteStatusLoaded(Result<FavoriteStatus, NetworkError>)

    case toggleFavoriteTapped
    case favoriteToggled(Result<String?, NetworkError>)

    case downloadBookTapped
    case downloadBookResponse(Result<[ChapterDTO], NetworkError>)

    case startReadingTapped
    case chapterTapped(order: Int)
    case openChapter(order: Int)

    case backButtonTapped
}

struct BookDetailsPayload: Equatable {
    let bookId: Int
    let documentId: String
    let title: String
    let author: String
    let description: String
    let coverURL: URL?
}
