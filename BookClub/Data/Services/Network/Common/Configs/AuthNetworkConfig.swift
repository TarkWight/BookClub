//
//  AuthNetworkConfig.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

enum AuthNetworkConfig: NetworkConfig {
    case refresh(Data)

    var path: String { "auth/" }

    var endPoint: String {
        switch self {
        case .refresh: return "local"
        }
    }

    var task: HTTPTask {
        switch self {
        case .refresh(let data):
            return .requestBody(data)
        }
    }

    var method: HTTPMethod {
        return .post
    }
}
