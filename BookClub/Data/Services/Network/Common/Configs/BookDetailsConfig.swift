//
//  BookDetailsConfig.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Alamofire
import Foundation

enum BookDetailsConfig: NetworkConfigProtocol {
    case getFavorites
    case addToFavorites(bookId: Int)
    case getBookById(id: Int)
    case getBookChapters(bookId: Int)
    case removeFromFavorites(favoriteId: String)

    var path: String {
        switch self {
        case .addToFavorites:
            return "favorites"
        case .getBookById:
            return "books"
        case .getBookChapters:
            return "chapters"
        case .removeFromFavorites(let favId):
            return "favorites/\(favId)"
        case .getFavorites:
            return "favorites"
        }
    }

    var endPoint: String { "" }

    var method: HTTPMethod {
        switch self {
        case .addToFavorites:
            return .post
        case .getBookById,
            .getBookChapters,
            .getFavorites:
            return .get
        case .removeFromFavorites:
            return .delete
        }
    }

    var parameters: Parameters? {
        switch self {
        case .addToFavorites(let bookId):
            return [
                "data": [
                    "bookId": bookId
                ]
            ]

        case .getBookById(let id):
            return [
                "filters[id]": id
            ]

        case .getBookChapters(let bookId):
            return [
                "filters[book][id][$eq]": bookId
            ]

        case .removeFromFavorites,
            .getFavorites:
            return nil
        }
    }

    var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
}
