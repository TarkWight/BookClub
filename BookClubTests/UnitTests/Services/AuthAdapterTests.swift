//
//  AuthAdapterTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import XCTest
@testable import BookClub

@MainActor
final class AuthAdapterTests: XCTestCase {

    func test_adapt_shouldAddAuthorizationHeader_whenTokenExists() async throws {
        let keychain = MockKeychainService()
        keychain.stubToken("jwt-abc")

        let sut = AuthAdapter(keychainService: keychain)

        var adaptedRequest: URLRequest?

        let exp = expectation(description: "Adapter completion")

        let url = try XCTUnwrap(URL(string: "https://example.com"))
        let originalRequest = URLRequest(url: url)

        sut.adapt(originalRequest, for: .default) { result in
            adaptedRequest = try? result.get()
            exp.fulfill()
        }

        await fulfillment(of: [exp], timeout: 1.0)

        let authHeader = adaptedRequest?.headers["Authorization"]
        XCTAssertEqual(authHeader, "Bearer jwt-abc")
    }

    func test_adapt_shouldFail_whenNoToken() async throws {
        let keychain = MockKeychainService()
        keychain.shouldThrowOnRetrieve = true

        let sut = AuthAdapter(keychainService: keychain)

        var capturedError: Error?
        let exp = expectation(description: "Adapter failure")

        let url = try XCTUnwrap(URL(string: "https://example.com"))
        let originalRequest = URLRequest(url: url)

        sut.adapt(originalRequest, for: .default) { result in
            if case let .failure(error) = result {
                capturedError = error
            }
            exp.fulfill()
        }

        await fulfillment(of: [exp], timeout: 1.0)

        XCTAssertNotNil(capturedError)
    }
}
