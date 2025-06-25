//
//  SearchEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

struct SearchEnvironment {
    let networkClient: NetworkClientProtocol
    let genreStorage: GenreStorageServiceProtocol
    let authorStorage: AuthorStorageServiceProtocol
    let recentSearchService: RecentSearchServiceProtocol
}
