//
//  LogInViewUITests.swift
//  BookClub
//
//  Created by Tark Wight on 25.03.2025.
//

import XCTest

final class LogInViewUITests: XCTestCase {
    private var app: XCUIApplication?
    private var screen: LogInScreen?

    override func setUpWithError() throws {
        continueAfterFailure = false

        let application = XCUIApplication()
        application.launch()

        app = application
        screen = LogInScreen(app: application)
    }

    func test_buttonIsDisabled_whenFieldsAreEmpty() {
        let button = unwrap(screen?.signInButton, "Sign In button not found")
        XCTAssertFalse(button.isEnabled)
    }

    func test_clearButtonAppears_whenEmailIsFilled() {
        screen?.enterEmail("test@example.com")
        let clearButton = unwrap(screen?.clearButton, "Clear button not found")
        XCTAssertTrue(clearButton.exists)
    }

    func test_clearButtonClearsEmail() {
        screen?.enterEmail("test@example.com")
        screen?.clearEmail()
        let emailField = unwrap(screen?.emailField, "Email field not found")
        XCTAssertEqual(emailField.value as? String, "")
    }

    func test_eyeIconHidden_whenPasswordEmpty() {
        let eyeButton = unwrap(screen?.eyeButton, "Eye button not found")
        XCTAssertFalse(eyeButton.exists)
    }

    func test_eyeIconTogglesPasswordVisibility() {
        screen?.enterPassword("password123")
        let eyeButton = unwrap(screen?.eyeButton)
        XCTAssertTrue(eyeButton.exists)
        screen?.togglePasswordVisibility()
        let visibleField = unwrap(screen?.visiblePasswordField)
        XCTAssertTrue(visibleField.exists)
    }
}
