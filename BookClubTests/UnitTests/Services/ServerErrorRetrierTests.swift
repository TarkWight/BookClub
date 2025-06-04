//
//  ServerErrorRetrierTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import XCTest
import Alamofire
@testable import BookClub

final class ServerErrorRetrierTests: XCTestCase {
    private var retrier: ServerErrorRetrier!

    override func setUp() {
        super.setUp()
        retrier = ServerErrorRetrier()
    }

    func test_makeRetryResult_shouldRetryOnServerError() {
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 503))
        let result = retrier.makeRetryResult(from: error)
        switch result {
        case .retryWithDelay(let delay):
            XCTAssertEqual(delay, 1.0)
        default:
            XCTFail("Expected .retryWithDelay, got \(result)")
        }
    }

    func test_makeRetryResult_shouldNotRetryOnClientError() {
        let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))
        let result = retrier.makeRetryResult(from: error)
        switch result {
        case .doNotRetry:
            break // success
        default:
            XCTFail("Expected .doNotRetry, got \(result)")
        }
    }

    func test_makeRetryResult_shouldNotRetryOnOtherError() {
        let error = URLError(.timedOut)
        let result = retrier.makeRetryResult(from: error)
        switch result {
        case .doNotRetry:
            break // success
        default:
            XCTFail("Expected .doNotRetry, got \(result)")
        }
    }
}
