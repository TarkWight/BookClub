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

    // MARK: – Token

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

    // MARK: – Identifier

    func test_saveRetrieveDeleteIdentifier_shouldWorkCorrectly() async throws {
        let identifier = "user-123"
        try await sut?.saveIdentifier(identifier)

        let retrieved = try await sut?.retrieveIdentifier()
        XCTAssertEqual(retrieved, identifier)

        try await sut?.deleteIdentifier()

        do {
            _ = try await sut?.retrieveIdentifier()
            XCTFail("Expected .identifierNotFound")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .identifierNotFound)
        }
    }

func test_retrieveIdentifier_whenMissing_shouldThrowIdentifierNotFound() async {
    do {
        _ = try await unwrap(sut?.retrieveIdentifier())
        XCTFail("Expected .identifierNotFound")
    } catch let error as KeychainError {
        XCTAssertEqual(error, .identifierNotFound)
    } catch {
        XCTFail("Unexpected error: \(error)")
    }
}

    func test_deleteIdentifier_whenAlreadyDeleted_shouldNotThrow() async throws {
        try await sut?.deleteIdentifier()
    }

    // MARK: – Password

    func test_saveRetrieveDeletePassword_shouldWorkCorrectly() async throws {
        let password = "securePassword123"
        try await sut?.savePassword(password)

        let retrieved = try await sut?.retrievePassword()
        XCTAssertEqual(retrieved, password)

        try await sut?.deletePassword()

        do {
            _ = try await sut?.retrievePassword()
            XCTFail("Expected .passwordNotFound")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .passwordNotFound)
        }
    }

    func test_retrievePassword_whenMissing_shouldThrowPasswordNotFound() async {
        do {
            _ = try await unwrap(sut?.retrievePassword())
            XCTFail("Expected .passwordNotFound")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .passwordNotFound)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_deletePassword_whenAlreadyDeleted_shouldNotThrow() async throws {
        try await sut?.deletePassword()
    }

    // MARK: – Delete All

    func test_deleteAllCredentials_shouldRemoveEverything() async throws {
        try await sut?.saveToken("abc")
        try await sut?.saveIdentifier("id-123")
        try await sut?.savePassword("pass")

        try await sut?.deleteAllCredentials()

        do {
            _ = try await sut?.retrieveToken()
            XCTFail("Expected .tokenNotFound")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .tokenNotFound)
        }

        do {
            _ = try await sut?.retrieveIdentifier()
            XCTFail("Expected .identifierNotFound")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .identifierNotFound)
        }

        do {
            _ = try await sut?.retrievePassword()
            XCTFail("Expected .passwordNotFound")
        } catch let error as KeychainError {
            XCTAssertEqual(error, .passwordNotFound)
        }
    }
}

extension XCTestCase {
    func unwrap<T>(_ optional: T?, _ message: String = "Failed to unwrap optional", file: StaticString = #file, line: UInt = #line) throws -> T {
        guard let value = optional else {
            XCTFail(message, file: file, line: line)
            throw TestError.unwrapFailed
        }
        return value
    }

    enum TestError: Error {
        case unwrapFailed
    }
}
