//
//  LibraryConfig.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Alamofire
import Foundation

enum LibraryConfig: NetworkConfigProtocol {
    case list(page: Int, pageSize: Int)
    case newBooks

    var path: String { "books/" }
    var endPoint: String { "" }
    var method: HTTPMethod { .get }
    var parameters: Parameters? {
        switch self {
        case let .list(page, size):
            return [
                "pagination[page]": page,
                "pagination[pageSize]": size,
            ]
        case .newBooks:
            return ["filters[isNew]": true]
        }
    }
    var headers: HTTPHeaders? { ["Accept": "application/json"] }
}
