//
//  SearchConfig.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Alamofire
import Foundation

enum SearchConfig: NetworkConfigProtocol {
    case booksByTitle(query: String)
    case booksByGenre(id: Int)
    case booksByAuthor(id: Int)
    case booksAll

    case authors
    case genres

    var path: String {
        switch self {
        case .booksByTitle, .booksByGenre, .booksByAuthor, .booksAll:
            return "books/"
        case .authors:
            return "authors/"
        case .genres:
            return "genres/"
        }
    }

    var endPoint: String { "" }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {
        case .booksByTitle(let query):
            return [
                "filters[title][$containsi]": query
            ]
        case .booksByGenre(let id):
            return [
                "filters[genres][id][$eq]": id
            ]
        case .booksByAuthor(let id):
            return [
                "filters[authors][id][$eq]": id
            ]
        case .booksAll:
            return nil
        case .authors, .genres:
            return nil
        }
    }

    var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
}
