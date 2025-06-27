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
    case notConnectedToInternet
    case timedOut
    case networkConnectionLost
    case otherURL(URLError)
    case unacceptableStatusCode(Int)
    case decodingError(String)
    case afError(AFError)

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case let (.invalidURL(lhsURL), .invalidURL(rhsURL)):
            return lhsURL == rhsURL

        case (.notConnectedToInternet, .notConnectedToInternet),
             (.timedOut, .timedOut),
             (.networkConnectionLost, .networkConnectionLost):
            return true

        case let (.otherURL(lhsError), .otherURL(rhsError)):
            return lhsError.code == rhsError.code

        case let (
            .unacceptableStatusCode(lhsCode),
            .unacceptableStatusCode(rhsCode)
        ):
            return lhsCode == rhsCode

        case let (.decodingError(lhsMsg), .decodingError(rhsMsg)):
            return lhsMsg == rhsMsg

        case let (.afError(lhsAF), .afError(rhsAF)):
            return lhsAF.errorDescription == rhsAF.errorDescription

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
        case .notConnectedToInternet:
            return LocalizedKey.noNetwork
        case .timedOut:
            return LocalizedKey.requestTimeout
        case .networkConnectionLost:
            return LocalizedKey.noNetwork
        case .otherURL:
            return LocalizedKey.noNetwork
        case .unacceptableStatusCode:
            return LocalizedKey.badStatusCode
        case .decodingError:
            return LocalizedKey.decodingError
        case .afError:
            return LocalizedKey.requestFailed
        }
    }
}
