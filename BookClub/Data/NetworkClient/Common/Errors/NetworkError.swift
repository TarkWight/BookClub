//
//  NetworkError.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Alamofire
import Foundation

enum NetworkError: Error, Equatable {
    case afError(AFError)
    case urlError(URLError)
    case unacceptableStatusCode(Int)
    case decodingError(String)

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case let (.afError(a), .afError(b)):
            return a.errorDescription == b.errorDescription
        case let (.urlError(a), .urlError(b)):
            return a.code == b.code
        case let (.unacceptableStatusCode(a), .unacceptableStatusCode(b)):
            return a == b
        case let (.decodingError(a), .decodingError(b)):
            return a == b
        default:
            return false
        }
    }
}

@MainActor
extension NetworkError {
    var localizedKey: String {
        switch self {
        case .afError:
            return LocalizedKey.requestFailed
        case .urlError:
            return LocalizedKey.noNetwork
        case .unacceptableStatusCode:
            return LocalizedKey.badStatusCode
        case .decodingError:
            return LocalizedKey.decodingError
        }
    }
}
