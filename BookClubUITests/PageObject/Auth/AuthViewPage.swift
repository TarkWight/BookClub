//
//  AuthViewPage.swift
//  BookClub
//
//  Created by Tark Wight on 01.04.2025.
//

import XCTest

class AuthViewPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    var emailTextField: XCUIElement {
        return app.textFields["emailTextField"]
    }

    var passwordTextField: XCUIElement {
        return app.textFields["passwordTextField"]
    }

    var secureTextField: XCUIElement {
        return app.secureTextFields["secureTextField"]
    }

    var clearButton: XCUIElement {
        return app.buttons["clearButton"]
    }

    var secureButton: XCUIElement {
        return app.buttons["secureButton"]
    }

    func enterEmail(_ email: String) {
        emailTextField.tap()
        emailTextField.typeText(email)
    }

    func enterPassword(_ password: String) {
        secureTextField.tap()
        secureTextField.typeText(password)
    }

    func togglePasswordVisibility() {
        secureButton.tap()
    }

    func clearEmail() {
        clearButton.tap()
    }
}
