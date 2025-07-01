//
//  AuthServiceTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import XCTest

@testable import BookClub

@MainActor
final class AuthServiceTests: XCTestCase {

    private var mockKeychain: MockKeychainService!
    private var mockNetwork: MockNetworkService!
    private var sut: AuthService!

    override func setUp() {
        super.setUp()
        mockKeychain = MockKeychainService()
        mockNetwork = MockNetworkService()
        sut = AuthService(
            networkClient: mockNetwork,
            keychainService: mockKeychain
        )
    }

    func test_refreshToken_success_shouldReturnTokenAndSaveToKeychain()
        async throws {
        mockKeychain.stubIdentifier("test_user")
        mockKeychain.stubPassword("pass123")

        // Prepare stubbed JSON for AuthResponse(jwt: "new-token-xyz")
        let auth = AuthResponse(jwt: "new-token-xyz")
        mockNetwork.stubbedData = try JSONEncoder().encode(auth)

        let token = try await sut.refreshToken()

        XCTAssertEqual(token, "new-token-xyz")
        XCTAssertEqual(mockKeychain.savedToken, "new-token-xyz")
    }

    func test_refreshToken_whenDecodingFails_shouldThrowDecodingError() async {
        mockKeychain.stubIdentifier("user")
        mockKeychain.stubPassword("pass")

        // Provide invalid JSON so decoding will fail
        mockNetwork.stubbedData = Data("not a valid JSON".utf8)

        do {
            _ = try await sut.refreshToken()
            XCTFail("Expected DecodingError")
        } catch is DecodingError {
            // success
        } catch {
            XCTFail("Expected DecodingError but got: \(error)")
        }
    }

    func test_refreshToken_whenNetworkFails_shouldThrowURLError() async {
        mockKeychain.stubIdentifier("test_user")
        mockKeychain.stubPassword("pass")

        mockNetwork.shouldThrowOnRequest = true

        do {
            _ = try await sut.refreshToken()
            XCTFail("Expected URLError")
        } catch is URLError {
            // success
        } catch {
            XCTFail("Expected URLError but got: \(error)")
        }
    }
}
