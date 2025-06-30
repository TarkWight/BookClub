//
//  LoginError.swift
//  BookClub
//
//  Created by Tark Wight on 07.06.2025.
//

import Foundation

enum LoginError: Error, Equatable {
    case network(NetworkError)
    case tokenNotFound
    case identifierNotFound
    case passwordNotFound
    case unexpectedData
    case invalidCredentials
    case unhandledError(OSStatus)

    static func == (lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
        case let (.network(errA), .network(errB)):
            return errA == errB
        case (.tokenNotFound, .tokenNotFound),
            (.identifierNotFound, .identifierNotFound),
            (.passwordNotFound, .passwordNotFound),
            (.unexpectedData, .unexpectedData),
            (.invalidCredentials, .invalidCredentials):
            return true
        case let (.unhandledError(errA), .unhandledError(errB)):
            return errA == errB
        default:
            return false
        }
    }
}

@MainActor
extension LoginError {
    var localizedKey: String {
        switch self {
        case .network(let err): return err.localizedKey
        case .tokenNotFound: return LocalizedKey.tokenNotFound
        case .identifierNotFound: return LocalizedKey.identifierNotFound
        case .passwordNotFound: return LocalizedKey.passwordNotFound
        case .unexpectedData: return LocalizedKey.unexpectedData
        case .unhandledError: return LocalizedKey.unhandledError
        case .invalidCredentials: return LocalizedKey.invalidCredentials
        }
    }
}
