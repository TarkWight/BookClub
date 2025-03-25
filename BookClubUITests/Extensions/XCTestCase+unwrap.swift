//
//  XCTestCase+unwrap.swift
//  BookClubUITests
//
//  Created by Tark Wight on 25.03.2025.
//

import XCTest

extension XCTestCase {
    func unwrap<T>(_ optional: T?, _ message: String = "Failed to unwrap optional", file: StaticString = #file, line: UInt = #line) -> T {
        guard let value = optional else {
            XCTFail(message, file: file, line: line)
            fatalError(message)
        }
        return value
    }
}
