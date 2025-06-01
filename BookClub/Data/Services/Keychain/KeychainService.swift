//
//  KeychainService.swift
//  BookClub
//
//  Created by Tark Wight on 29.05.2025.
//

import Security
import Foundation

final class KeychainService: KeychainServiceProtocol {
    private let service = Bundle.main.bundleIdentifier ?? "BookClubService"

    private enum Account: String {
        case token       = "authToken"
        case identifier  = "userIdentifier"
        case password    = "userPassword"
    }

    // MARK: – Token

    func saveToken(_ token: String) async throws {
        let data = Data(token.utf8)
        let accountKey = Account.token.rawValue

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status)
        }
    }

    func retrieveToken() async throws -> String {
        let accountKey = Account.token.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard
                let data = result as? Data,
                let token = String(data: data, encoding: .utf8)
            else {
                throw KeychainError.unexpectedData
            }
            return token

        case errSecItemNotFound:
            throw KeychainError.tokenNotFound

        default:
            throw KeychainError.unhandledError(status)
        }
    }

    func deleteToken() async throws {
        let accountKey = Account.token.rawValue
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status)
        }
    }

    // MARK: – Identifier

    func saveIdentifier(_ identifier: String) async throws {
        let data = Data(identifier.utf8)
        let accountKey = Account.identifier.rawValue

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status)
        }
    }

    func retrieveIdentifier() async throws -> String {
        let accountKey = Account.identifier.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard
                let data = result as? Data,
                let identifier = String(data: data, encoding: .utf8)
            else {
                throw KeychainError.unexpectedData
            }
            return identifier

        case errSecItemNotFound:
            throw KeychainError.identifierNotFound

        default:
            throw KeychainError.unhandledError(status)
        }
    }

    func deleteIdentifier() async throws {
        let accountKey = Account.identifier.rawValue
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status)
        }
    }

    // MARK: – Password

    func savePassword(_ password: String) async throws {
        let data = Data(password.utf8)
        let accountKey = Account.password.rawValue

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status)
        }
    }

    func retrievePassword() async throws -> String {
        let accountKey = Account.password.rawValue
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard
                let data = result as? Data,
                let password = String(data: data, encoding: .utf8)
            else {
                throw KeychainError.unexpectedData
            }
            return password

        case errSecItemNotFound:
            throw KeychainError.passwordNotFound

        default:
            throw KeychainError.unhandledError(status)
        }
    }

    func deletePassword() async throws {
        let accountKey = Account.password.rawValue
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status)
        }
    }

    // MARK: – Delete All

    func deleteAllCredentials() async throws {
        try await deleteToken()
        try await deleteIdentifier()
        try await deletePassword()
    }
}
