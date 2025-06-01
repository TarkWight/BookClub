//
//  KeychainError.swift
//  BookClub
//
//  Created by Tark Wight on 31.05.2025.
//

import Foundation

enum KeychainError: Error, Equatable {
    case tokenNotFound
    case identifierNotFound
    case passwordNotFound
    case unexpectedData
    case unhandledError(OSStatus)

    static func == (lhs: KeychainError, rhs: KeychainError) -> Bool {
        switch (lhs, rhs) {
        case (.tokenNotFound, .tokenNotFound),
             (.identifierNotFound, .identifierNotFound),
             (.passwordNotFound, .passwordNotFound),
             (.unexpectedData, .unexpectedData):
            return true
        case let (.unhandledError(code1), .unhandledError(code2)):
            return code1 == code2
        default:
            return false
        }
    }
}
