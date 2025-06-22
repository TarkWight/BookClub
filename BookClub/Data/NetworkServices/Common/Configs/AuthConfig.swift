//
//  AuthConfig.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import Foundation

enum AuthConfig: NetworkConfigProtocol {
    case login(identifier: String, password: String)

    var path: String { "auth" }
    var endPoint: String { "local" }
    var method: HTTPMethod { .post }
    var parameters: Parameters? {
        switch self {
        case let .login(id, pw):
            return ["identifier": id, "password": pw]
        }
    }
    var headers: HTTPHeaders? { nil }
}
