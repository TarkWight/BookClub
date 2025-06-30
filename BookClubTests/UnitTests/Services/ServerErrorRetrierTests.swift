//
//  ServerErrorRetrierTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import XCTest

@testable import BookClub

final class ServerErrorRetrierTests: XCTestCase {
    private var retrier: ServerErrorRetrier!
    private var session: Session!
    private var request: DataRequest!

    override func setUp() {
        super.setUp()
        retrier = ServerErrorRetrier()
        let config = URLSessionConfiguration.ephemeral
        session = Session(configuration: config)
        let url = URL(string: "https://example.com")!
        request = session.request(url)
    }

    func test_retry_retriesOnNetworkErrors() {
        let networkErrorCodes: [URLError.Code] = [
            .timedOut,
            .notConnectedToInternet,
            .networkConnectionLost,
        ]
        for code in networkErrorCodes {
            let error = URLError(code)
            let exp = expectation(
                description: "retry for URLError.\(code.rawValue)"
            )
            var actualResult: RetryResult?
            retrier.retry(request, for: session, dueTo: error) { result in
                actualResult = result
                exp.fulfill()
            }
            wait(for: [exp], timeout: 0.1)
            switch actualResult {
            case .retry:
                break  // success
            default:
                XCTFail(
                    "Expected .retry for URLError.\(code.rawValue), got \(String(describing: actualResult))"
                )
            }
        }
    }

    func test_retry_retriesOnServer5xx() {
        let codes = [500, 503, 599]
        for code in codes {
            let afError = AFError.responseValidationFailed(
                reason: .unacceptableStatusCode(code: code)
            )
            let exp = expectation(description: "retry for 5xx \(code)")
            var actualResult: RetryResult?
            retrier.retry(request, for: session, dueTo: afError) { result in
                actualResult = result
                exp.fulfill()
            }
            wait(for: [exp], timeout: 0.1)
            switch actualResult {
            case .retry:
                break  // success
            default:
                XCTFail(
                    "Expected .retry for status code \(code), got \(String(describing: actualResult))"
                )
            }
        }
    }

    func test_retry_doesNotRetryOnClient4xx() {
        let codes = [400, 404, 418]
        for code in codes {
            let afError = AFError.responseValidationFailed(
                reason: .unacceptableStatusCode(code: code)
            )
            let exp = expectation(description: "no retry for 4xx \(code)")
            var actualResult: RetryResult?
            retrier.retry(request, for: session, dueTo: afError) { result in
                actualResult = result
                exp.fulfill()
            }
            wait(for: [exp], timeout: 0.1)
            switch actualResult {
            case .doNotRetry:
                break  // success
            default:
                XCTFail(
                    "Expected .doNotRetry for status code \(code), got \(String(describing: actualResult))"
                )
            }
        }
    }
}
