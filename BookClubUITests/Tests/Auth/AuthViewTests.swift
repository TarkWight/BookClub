//
//  AuthViewTests.swift
//  BookClub
//
//  Created by Tark Wight on 01.04.2025.
//

import XCTest

final class AuthViewTests: XCTestCase {

    private var app: XCUIApplication?
    private var credentialPage: AuthViewPage?

    override func setUp() {
        super.setUp()

        let launchedApp = XCUIApplication()
        launchedApp.launch()

        app = launchedApp
        credentialPage = AuthViewPage(app: launchedApp)

        continueAfterFailure = false
    }

    func testEmailInput() {
        let credentialPage = unwrap(self.credentialPage, "CredentialPage is not initialized.")

        credentialPage.enterEmail("test@example.com")

        let emailText = unwrap(credentialPage.emailTextField.value as? String)
        XCTAssertEqual(emailText, "test@example.com")
        XCTAssertTrue(credentialPage.clearButton.exists)
    }

    func testPasswordInput() {
        let credentialPage = unwrap(self.credentialPage, "CredentialPage is not initialized.")

        credentialPage.enterPassword("password123")

        XCTAssertTrue(credentialPage.secureButton.exists)
    }

    func testTogglePasswordVisibility() {
        let credentialPage = unwrap(self.credentialPage, "CredentialPage is not initialized.")

        credentialPage.enterPassword("password123")
        credentialPage.togglePasswordVisibility()

        XCTAssertTrue(credentialPage.passwordTextField.exists)
    }

    func testClearEmail() {
        let credentialPage = unwrap(self.credentialPage, "CredentialPage is not initialized.")

        credentialPage.enterEmail("test@example.com")
        credentialPage.clearEmail()

        let emailText = unwrap(credentialPage.emailTextField.value as? String)
        XCTAssertEqual(emailText, "")
        XCTAssertFalse(credentialPage.clearButton.exists)
    }

    func testFullInputAndReset() {
        let credentialPage = unwrap(self.credentialPage, "CredentialPage is not initialized.")

        credentialPage.enterEmail("user@example.com")
        XCTAssertTrue(credentialPage.clearButton.exists)

        credentialPage.enterPassword("SecurePassword123")
        XCTAssertTrue(credentialPage.secureButton.exists)

        credentialPage.clearEmail()
        XCTAssertFalse(credentialPage.clearButton.exists)

        let emailText = unwrap(credentialPage.emailTextField.value as? String)
        XCTAssertEqual(emailText, "")

        credentialPage.togglePasswordVisibility()

        credentialPage.passwordTextField.clearText()
        XCTAssertFalse(credentialPage.secureButton.exists)

        let passwordText = unwrap(credentialPage.passwordTextField.value as? String)
        XCTAssertEqual(passwordText, "")
    }
}
