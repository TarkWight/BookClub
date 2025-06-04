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
        sut = AuthService(networkService: mockNetwork, keychainService: mockKeychain)
    }

    func test_refreshToken_success_shouldReturnTokenAndSaveToKeychain() async throws {
        mockKeychain.stubIdentifier("test_user")
        mockKeychain.stubPassword("pass123")
        mockNetwork.stubbedResponse = AuthResponse(accessToken: "new-token-xyz")

        let token = try await sut.refreshToken()

        XCTAssertEqual(token, "new-token-xyz")
        XCTAssertEqual(mockKeychain.savedToken, "new-token-xyz")
    }

    func test_refreshToken_whenEncodingFails_shouldThrow() async {
        mockKeychain.stubIdentifier("user")
        mockKeychain.stubPassword("pass")
        mockNetwork.shouldThrowOnEncode = true
        mockNetwork.stubbedResponse = AuthResponse(accessToken: "will-never-use")

        do {
            _ = try await sut.refreshToken()
            XCTFail("Expected EncodingError")
        } catch _ as EncodingError {
            // success
        } catch {
            XCTFail("Expected EncodingError but got: \(error)")
        }
    }

    func test_refreshToken_whenNetworkFails_shouldThrow() async {
        mockKeychain.stubIdentifier("test_user")
        mockKeychain.stubPassword("pass")
        mockNetwork.shouldThrowOnRequest = true

        do {
            _ = try await sut.refreshToken()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}
