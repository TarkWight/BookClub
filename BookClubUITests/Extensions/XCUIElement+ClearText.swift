//
//  XCUIElement+ClearText.swift
//  BookClubUITests
//
//  Created by Tark Wight on 01.04.2025.
//

import XCTest

extension XCUIElement {
    func clearText() {
        guard self.exists && self.isHittable else {
            XCTFail("Element is not hittable or doesn't exist.")
            return
        }

        self.tap()

        if let value = self.value as? String, !value.isEmpty {
            let deleteString = String(repeating: "\u{8}", count: value.count)
            self.typeText(deleteString)
        } else {
            XCTFail("TextField is either empty or not editable.")
        }
    }
}
