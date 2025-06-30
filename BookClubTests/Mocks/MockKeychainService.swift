//
//  MockKeychainService.swift
//  BookClubTests
//
//  Created by Tark Wight on 31.05.2025.
//

@testable import BookClub

@MainActor
final class MockKeychainService: KeychainServiceProtocol {

    private(set) var savedToken: String?
    private(set) var savedIdentifier: String?
    private(set) var savedPassword: String?

    private(set) var didCallSave = false
    private(set) var didCallDelete = false

    var shouldThrowOnRetrieve = false

    // MARK: – Stubs

    func stubToken(_ value: String) {
        savedToken = value
    }

    func stubIdentifier(_ value: String) {
        savedIdentifier = value
    }

    func stubPassword(_ value: String) {
        savedPassword = value
    }

    func clearAllStubs() {
        savedToken = nil
        savedIdentifier = nil
        savedPassword = nil
        didCallSave = false
        didCallDelete = false
    }

    // MARK: – Token

    func saveToken(_ token: String) async throws {
        savedToken = token
        didCallSave = true
    }

    func retrieveToken() async throws -> String {
        if shouldThrowOnRetrieve {
            throw KeychainError.tokenNotFound
        }

        guard let token = savedToken else {
            throw KeychainError.tokenNotFound
        }

        return token
    }

    func deleteToken() async throws {
        savedToken = nil
        didCallDelete = true
    }

    // MARK: – Identifier

    func saveIdentifier(_ identifier: String) async throws {
        savedIdentifier = identifier
    }

    func retrieveIdentifier() async throws -> String {
        guard let identifier = savedIdentifier else {
            throw KeychainError.identifierNotFound
        }
        return identifier
    }

    func deleteIdentifier() async throws {
        savedIdentifier = nil
    }

    // MARK: – Password

    func savePassword(_ password: String) async throws {
        savedPassword = password
    }

    func retrievePassword() async throws -> String {
        guard let password = savedPassword else {
            throw KeychainError.passwordNotFound
        }
        return password
    }

    func deletePassword() async throws {
        savedPassword = nil
    }

    // MARK: – Delete All

    func deleteAllCredentials() async throws {
        try await deleteToken()
        try await deleteIdentifier()
        try await deletePassword()
    }
}
