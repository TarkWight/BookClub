//
//  MockKeychainService.swift
//  BookClubTests
//
//  Created by Tark Wight on 31.05.2025.
//

@testable import BookClub

final class MockKeychainService: KeychainServiceProtocol {

    private(set) var savedToken: String?
    private(set) var didCallSave = false
    private(set) var didCallDelete = false

    func saveToken(_ token: String) async throws {
        savedToken = token
        didCallSave = true
    }

    func retrieveToken() async throws -> String {
        guard let token = savedToken else {
            throw KeychainError.tokenNotFound
        }
        return token
    }

    func deleteToken() async throws {
        savedToken = nil
        didCallDelete = true
    }
}
