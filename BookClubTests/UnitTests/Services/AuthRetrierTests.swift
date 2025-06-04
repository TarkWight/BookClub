//
//  AuthRetrierTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import XCTest
@testable import BookClub
import Alamofire

@MainActor
final class AuthRetrierTests: XCTestCase {
    private var retrier: AuthRetrier!
    private var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        retrier = AuthRetrier(authService: mockAuthService)
    }

    // MARK: - shouldRetry logic

    func test_shouldRetry_whenStatusCode401_returnsTrue() {
        XCTAssertTrue(retrier.shouldRetry(statusCode: 401))
    }

    func test_shouldRetry_whenStatusCodeNot401_returnsFalse() {
        XCTAssertFalse(retrier.shouldRetry(statusCode: 403))
        XCTAssertFalse(retrier.shouldRetry(statusCode: nil))
    }

    // MARK: - Integration-like behavior with mockAuthService

    func test_retry_shouldTriggerRefresh_when401() async {
        let exp = expectation(description: "Should retry")
        mockAuthService.shouldSucceed = true

        let completion: @Sendable  (RetryResult) -> Void = { result in
            if case .retry = result {
                exp.fulfill()
            } else {
                XCTFail("Expected .retry")
            }
        }

        retrier.simulateRetry(statusCode: 401, completion: completion)

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
        mockAuthService.shouldSucceed = false

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
        mockAuthService.shouldSucceed = true

        retrier.simulateRetry(statusCode: 401) { result in
            if case .retry = result {
                exp1.fulfill()
            }
        }

        retrier.simulateRetry(statusCode: 401) { result in
            if case .retry = result {
                exp2.fulfill()
            }
        }

        await fulfillment(of: [exp1, exp2], timeout: 1.0)
        XCTAssertEqual(mockAuthService.refreshTokenCallCount, 1)
    }
}

// MARK: - Extension for testing private logic
#if DEBUG
extension AuthRetrier {
    func simulateRetry(statusCode: Int?, completion: @escaping @Sendable (RetryResult) -> Void) {
        if shouldRetry(statusCode: statusCode) {
            Task {
                await retryManager.enqueue(completion)
            }
        } else {
            completion(.doNotRetry)
        }
    }
}
#endif
