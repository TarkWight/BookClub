//
//  KeychainServiceTests.swift
//  BookClubTests
//
//  Created by Tark Wight on 31.05.2025.
//

import XCTest
@testable import BookClub

final class KeychainServiceTests: XCTestCase {

    private var sut: KeychainService?

    override func setUp() {
        super.setUp()
        sut = KeychainService()
    }

    override func tearDown() {
        Task {
            try? await sut?.deleteToken()
        }
        super.tearDown()
    }

    func test_saveToken_shouldStoreToken() async throws {
        let token = "abc123"

        try await sut?.saveToken(token)

        let result = try await sut?.retrieveToken()
        XCTAssertEqual(result, token)
    }

    func test_retrieveToken_whenNoToken_shouldThrowTokenNotFound() async {
        do {
            _ = try await sut?.retrieveToken()
            XCTFail("Expected tokenNotFound error")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .tokenNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deleteToken_shouldRemoveStoredToken() async throws {
        try await sut?.saveToken("abc")
        try await sut?.deleteToken()

        do {
            _ = try await sut?.retrieveToken()
            XCTFail("Expected tokenNotFound error after delete")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .tokenNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deleteToken_whenNoToken_shouldNotThrow() async throws {
        do {
            try await sut?.deleteToken()
        } catch {
            XCTFail("Expected no error when deleting non-existent token, got: \(error)")
        }
    }
}
