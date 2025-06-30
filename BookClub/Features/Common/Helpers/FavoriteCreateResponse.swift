//
//  FavoriteCreateResponse.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct FavoriteCreateResponse: Decodable {
    let data: FavoriteItem

    private enum CodingKeys: String, CodingKey {
        case data
    }
}
