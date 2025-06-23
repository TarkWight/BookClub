//
//  SearchAction.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

enum SearchAction: Equatable {
    // MARK: – Local storage (DB)
    case fetchLocalGenres
    case localGenresLoaded([GenreItem])

    case fetchLocalAuthors
    case localAuthorsLoaded([AuthorItem])

    case fetchRecentSearches
    case RecentSearchesLoaded([RecentSearches])

    // MARK: – Network (API)
	case requestFindBooksByName(query: String)
    case findBooksByNameResponse(Result<[BookDetailsItem], NetworkError>)

    case requestFindBooksByGenre(genreID: String)
    case findBooksByGenreResponse(Result<[BookDetailsItem], NetworkError>)
    
    case requestFindBooksByAuthor(authorID: String)
    case findBooksByAuthorResponse(Result<[BookDetailsItem], NetworkError>)

    case requestGetAuthors
    case findAuthorsResponse(Result<[AuthorItem], NetworkError>)

    case requestGetGenres
    case findGenresResponse(Result<[GenreItem], NetworkError>)

    // MARK: - Part 1 selected
    case dedSelectAuthor(authorID: String)
    case dedSelectGenre(genreID: String)
    case didSelectSearchQuery(query: String)
    case didSearchQueryClear
    case didSearchTapped(query: String)

    // MARK: – Part 2 selected
    case didSelectBook(documentID: String)
}
