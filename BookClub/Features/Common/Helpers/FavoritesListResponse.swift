//
//  FavoritesListResponse.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct FavoritesListResponse: Codable {
    struct Meta: Codable {
        struct Pagination: Codable {
            let page: Int
            let pageSize: Int
            let pageCount: Int
            let total: Int
        }

        let pagination: Pagination
    }

    let data: [FavoriteItem]
    let meta: Meta
}

