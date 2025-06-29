//
//  BookDetailsAction.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

enum BookDetailsAction: Equatable {
    case configure(
         bookId: Int,
         documentId: String,
         title: String,
         author: String,
         description: String,
         coverURL: URL?
       )

    case onAppear

    case chaptersLoaded(Result<[ChapterSummary], NetworkError>)
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
