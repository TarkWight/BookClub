//
//  AuthRetrierTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import XCTest

@testable import BookClub

@MainActor
final class AuthRetrierTests: XCTestCase {
    private var retrier: AuthRetrier!
    private var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        retrier = AuthRetrier(authService: mockAuthService)
    }

    // MARK: – shouldRetry logic

    func test_shouldRetry_whenStatusCode401_returnsTrue() {
        XCTAssertTrue(retrier.shouldRetry(statusCode: 401))
    }

    func test_shouldRetry_whenStatusCodeNot401_returnsFalse() {
        XCTAssertFalse(retrier.shouldRetry(statusCode: 403))
        XCTAssertFalse(retrier.shouldRetry(statusCode: nil))
    }

    // MARK: – simulateRetry integration

    func test_retry_shouldTriggerRefresh_when401() async {
        let exp = expectation(description: "Should retry")
        mockAuthService.shouldSucceedRefresh = true

        retrier.simulateRetry(statusCode: 401) { result in
            if case .retry = result {
                exp.fulfill()
            } else {
                XCTFail("Expected .retry")
            }
        }

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func test_retry_shouldNotRetry_whenNon401() async {
        let exp = expectation(description: "Should not retry")

        retrier.simulateRetry(statusCode: 403) { result in
            if case .doNotRetry = result {
                exp.fulfill()
            } else {
                XCTFail("Expected .doNotRetry")
            }
        }

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func test_retry_shouldFailAll_whenRefreshFails() async {
        let exp = expectation(description: "Should fail all")
        mockAuthService.shouldSucceedRefresh = false

        retrier.simulateRetry(statusCode: 401) { result in
            if case .doNotRetryWithError = result {
                exp.fulfill()
            } else {
                XCTFail("Expected .doNotRetryWithError")
            }
        }

        await fulfillment(of: [exp], timeout: 1.0)
    }

    func test_retry_shouldQueueMultipleCompletions_andCallRefreshOnce() async {
        let exp1 = expectation(description: "First completion")
        let exp2 = expectation(description: "Second completion")
        mockAuthService.shouldSucceedRefresh = true

        retrier.simulateRetry(statusCode: 401) { result in
            if case .retry = result { exp1.fulfill() }
        }
        retrier.simulateRetry(statusCode: 401) { result in
            if case .retry = result { exp2.fulfill() }
        }

        await fulfillment(of: [exp1, exp2], timeout: 1.0)
        XCTAssertEqual(mockAuthService.refreshTokenCallCount, 1)
    }
}
