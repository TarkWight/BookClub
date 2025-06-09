//
//  NetworkError.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

enum NetworkError: Sendable, Error, Equatable {
  case invalidURL(String)
  case unacceptableStatusCode(Int)
  case noData
  case decodingError(String)
  case underlying(String)
  case noNetwork
  case vpnActive
}

@MainActor
extension NetworkError {
    var localizedKey: String {
        switch self {
        case .noNetwork:
            return LocalizedKey.noNetwork
        case .vpnActive:
            return LocalizedKey.vpnActive
        case .unacceptableStatusCode:
            return LocalizedKey.badStatusCode
        case .decodingError:
            return LocalizedKey.decodingError
        case .noData:
            return LocalizedKey.noData
        default:
            return LocalizedKey.networkError
        }
    }
}
