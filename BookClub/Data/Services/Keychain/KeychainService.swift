//
//  KeychainService.swift
//  BookClub
//
//  Created by Tark Wight on 29.05.2025.
//

import Security
import Foundation

final class KeychainService: KeychainServiceProtocol {

    private let account: String = "authToken"
    private let service = Bundle.main.bundleIdentifier ?? "BookClubService"

    func saveToken(_ token: String) async throws {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess
        else {
            throw KeychainError.unhandledError(status)
        }
    }

    func retrieveToken() async throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound
        else {
            throw KeychainError.tokenNotFound
        }

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.unexpectedData
        }

        return token
    }

    func deleteToken() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound
        else {
            throw KeychainError.unhandledError(status)
        }
    }
}
