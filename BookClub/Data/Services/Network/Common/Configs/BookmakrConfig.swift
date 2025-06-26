//
//  BookmakrConfig.swift
//  BookClub
//
//  Created by Tark Wight on 26.06.2025.
//

import Alamofire
import Foundation

enum BookmakrConfig: NetworkConfigProtocol {
    case favorites
    case quotes

    var path: String {
        switch self {
        case .favorites:
            return "favorites"
        case .quotes:
            return "quotes"
        }

    }

    var endPoint: String { "" }

    var method: Alamofire.HTTPMethod { .get }

    var parameters: Alamofire.Parameters? { nil }

    var headers: HTTPHeaders? { ["Accept": "application/json"] }

}
