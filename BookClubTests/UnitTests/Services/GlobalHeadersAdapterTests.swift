//
//  GlobalHeadersAdapterTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import XCTest

@testable import BookClub

final class GlobalHeadersAdapterTests: XCTestCase {
    private var mockProvider: MockTokenProvider!
    private var adapter: GlobalHeadersAdapter!
    private let session = Session.default

    override func setUp() {
        super.setUp()
        mockProvider = MockTokenProvider()
        adapter = GlobalHeadersAdapter(tokenProvider: mockProvider)
    }

    func test_adapt_withToken_addsAuthorizationHeader() {
        // Given
        mockProvider.token = "abc123"
        let url = URL(string: "https://example.com")!
        var originalRequest = URLRequest(url: url)
        originalRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let exp = expectation(description: "Adapted")
        // When
        adapter.adapt(originalRequest, for: session) { result in
            do {
                let adapted = try result.get()
                // Then
                XCTAssertEqual(
                    adapted.value(forHTTPHeaderField: "Authorization"),
                    "Bearer abc123",
                    "Should inject correct Bearer token"
                )
                // Ensure other headers are preserved
                XCTAssertEqual(
                    adapted.value(forHTTPHeaderField: "Accept"),
                    "application/json"
                )
            } catch {
                XCTFail("adapt failed: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_adapt_withoutToken_doesNotAddAuthorizationHeader() {
        // Given
        mockProvider.token = nil
        let url = URL(string: "https://example.com")!
        let originalRequest = URLRequest(url: url)

        let exp = expectation(description: "Adapted")
        // When
        adapter.adapt(originalRequest, for: session) { result in
            do {
                let adapted = try result.get()
                // Then
                XCTAssertNil(
                    adapted.value(forHTTPHeaderField: "Authorization"),
                    "Should not add Authorization header when token is nil"
                )
            } catch {
                XCTFail("adapt failed: \(error)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
