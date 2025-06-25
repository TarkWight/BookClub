//
//  SearchAction.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

enum SearchAction: Equatable {
    // MARK: — Lifecycle
    case onAppear
    case dismissError

    // MARK: — UI
    case didChangeSearchText(String)
    case didTapSearch
    case didClearSearch
    case didSelectRecentSearch(String)
    case didSelectGenre(GenreItem)
    case didSelectAuthor(AuthorItem)
    case didSelectBook(documentId: String)

    // MARK: — Recent Searches
    case addRecentSearch(String)
    case fetchRecentSearches
    case recentSearchesLoaded([String])

    // MARK: — Local DB (genres/authors)
    case fetchLocalGenres
    case localGenresLoaded([GenreItem])
    case fetchLocalAuthors
    case localAuthorsLoaded([AuthorItem])

    // MARK: — Remote (Network): Genres
    case fetchRemoteGenres
    case remoteGenresLoaded(Result<[GenreItem], NetworkError>)

    // MARK: — Remote (Network): Authors
    case fetchRemoteAuthors
    case remoteAuthorsLoaded(Result<[AuthorItem], NetworkError>)

    // MARK: — Remote (Network): Books
    case fetchBooksByText(String)
    case booksByTextLoaded(Result<[BookDetailsItem], NetworkError>)

    case fetchBooksByGenre(GenreItem)
    case booksByGenreLoaded(Result<[BookDetailsItem], NetworkError>)

    case fetchBooksByAuthor(AuthorItem)
    case booksByAuthorLoaded(Result<[BookDetailsItem], NetworkError>)
}
