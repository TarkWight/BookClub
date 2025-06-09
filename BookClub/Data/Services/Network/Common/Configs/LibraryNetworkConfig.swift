//
//  LibraryNetworkConfig.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

enum LibraryNetworkConfig: NetworkConfig {
    case list(page: Int, pageSize: Int)
    case newBooks

    var path: String { "books" }

    var endPoint: String { "" }

    var task: HTTPTask {
        switch self {
        case let .list(page, pageSize):
            return .requestUrlParameters([
                "pagination[page]": page,
                "pagination[pageSize]": pageSize
            ])
        case .newBooks:
            return .requestUrlParameters([
                "filter[isNew]": true
            ])
        }
    }

    var method: HTTPMethod { .get }
}
