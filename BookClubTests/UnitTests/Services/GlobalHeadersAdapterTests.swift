//
//  GlobalHeadersAdapterTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import XCTest
import Alamofire
@testable import BookClub

final class GlobalHeadersAdapterTests: XCTestCase {
    func test_adapt_shouldAddAcceptLanguageHeader() throws {
        let adapter = GlobalHeadersAdapter()
        let url = try XCTUnwrap(URL(string: "https://example.com"))

        let originalRequest = URLRequest(url: url)
        let exp = expectation(description: "Adapted")

        adapter.adapt(originalRequest, for: .default) { result in
            do {
                let adaptedRequest = try result.get()
                let header = adaptedRequest.headers["Accept-Language"]
                XCTAssertEqual(header, Locale.current.identifier)
                exp.fulfill()
            } catch {
                XCTFail("Adaptation failed with error: \(error)")
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}
