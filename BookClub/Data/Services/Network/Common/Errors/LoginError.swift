//
//  LoginError.swift
//  BookClub
//
//  Created by Tark Wight on 07.06.2025.
//

import Foundation

enum LoginError: Error, Equatable {
    case tokenNotFound
    case identifierNotFound
    case passwordNotFound
    case unexpectedData
    case unhandledError(OSStatus)
    case network(NetworkError)

    static func == (lhs: LoginError, rhs: LoginError) -> Bool {
        switch (lhs, rhs) {
        case (.tokenNotFound, .tokenNotFound),
            (.identifierNotFound, .identifierNotFound),
            (.passwordNotFound, .passwordNotFound),
            (.unexpectedData, .unexpectedData):
            return true

        case let (.unhandledError(error1), .unhandledError(error2)):
            return error1 == error2

        case let (.network(error1), .network(error2)):
            return error1 == error2

        default:
            return false
        }
    }
}

@MainActor
extension LoginError {
    var localizedKey: String {
        switch self {
        case .tokenNotFound:
            return LocalizedKey.tokenNotFound
        case .identifierNotFound:
            return LocalizedKey.identifierNotFound
        case .passwordNotFound:
            return LocalizedKey.passwordNotFound
        case .unexpectedData:
            return LocalizedKey.unexpectedData
        case .unhandledError:
            return LocalizedKey.unhandledError
        case let .network(netErr):
            return netErr.localizedKey
        }
    }

    var localizedDescription: String {
        NSLocalizedString(self.localizedKey, comment: "")
    }
}
