//
//  NetworkError.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Alamofire
import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL(String)
    case afError(AFError)
    case urlError(URLError)
    case unacceptableStatusCode(Int)
    case decodingError(String)

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidURL(lhsURLString), .invalidURL(rhsURLString)):
            return lhsURLString == rhsURLString

        case let (.afError(lhsAFError), .afError(rhsAFError)):
            return lhsAFError.errorDescription == rhsAFError.errorDescription

        case let (.urlError(lhsURLError), .urlError(rhsURLError)):
            return lhsURLError.code == rhsURLError.code

        case let (
            .unacceptableStatusCode(lhsCode), .unacceptableStatusCode(rhsCode)
        ):
            return lhsCode == rhsCode

        case let (.decodingError(lhsMsg), .decodingError(rhsMsg)):
            return lhsMsg == rhsMsg

        default:
            return false
        }
    }
}

@MainActor
extension NetworkError {
    var localizedKey: String {
        switch self {
        case .invalidURL:
            return LocalizedKey.urlError
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
