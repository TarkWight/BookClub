//
//  TextHighlightingServiceTests.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Combine
import XCTest

@testable import BookClub

final class TextHighlightingServiceTests: XCTestCase {
    var service: TextHighlightingService!

    override func setUp() {
        super.setUp()
        service = TextHighlightingService()
    }

    override func tearDown() async throws {
        await service.stop()
        service = nil
        try await Task.sleep(nanoseconds: 10_000_000)
    }

    func testPrepareHighlightingSplitsSentences() async throws {
        let text = "Hello world. This is a test! And another?"
        await service.prepareHighlighting(for: text)

        var received: [Int] = []
        let exp = expectation(description: "all sentences highlighted")
        exp.expectedFulfillmentCount = 3

        Task {
            await service.start(interval: 0.01) { idx in
                received.append(idx)
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(received, [0, 1, 2])
    }

    func testStopResetsState() async throws {
        let expect = expectation(description: "highlight called once")
        expect.expectedFulfillmentCount = 1

        let svc = TextHighlightingService()
        await svc.prepareHighlighting(for: "Hello. World.")
        await svc.start(interval: 0.001) { _ in
            expect.fulfill()
        }

        // ждём один тик
        try await Task.sleep(nanoseconds: 2_000_000)
        await svc.stop()

        // теперь асинхронно ждём
        await fulfillment(of: [expect], timeout: 1.0)
    }

    func testLeakTextHighlightingService() async throws {
        weak var weakService: TextHighlightingService?

        let handle: Task<Void, Never> = autoreleasepool {
            let svc = TextHighlightingService()
            weakService = svc

            return Task.detached {
                await svc.prepareHighlighting(for: "A. B.")
                await svc.start(interval: 0.001) { _ in }
                try? await Task.sleep(nanoseconds: 5_000_000)
                await svc.stop()
            }
        }

        await handle.value

        try await Task.sleep(nanoseconds: 10_000_000)

        XCTAssertNil(
            weakService,
            "TextHighlightingService должен освободиться из памяти после stop() и окончания всех задач"
        )
    }
}
