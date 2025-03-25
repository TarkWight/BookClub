//
//  LogInScreen.swift
//  BookClub
//
//  Created by Tark Wight on 25.03.2025.
//

import XCTest

struct LogInScreen {
    let app: XCUIApplication

    var emailField: XCUIElement {
        app.textFields["emailField"]
    }

    var securePasswordField: XCUIElement {
        app.secureTextFields["securePasswordField"]
    }

    var visiblePasswordField: XCUIElement {
        app.textFields["visiblePasswordField"]
    }

    var clearButton: XCUIElement {
        app.buttons["clearButton"]
    }

    var eyeButton: XCUIElement {
        app.buttons["togglePasswordVisibility"]
    }

    var signInButton: XCUIElement {
        app.buttons["Войти"]
    }

    func enterEmail(_ text: String) {
        emailField.tap()
        emailField.typeText(text)
    }

    func enterPassword(_ text: String) {
        securePasswordField.tap()
        securePasswordField.typeText(text)
    }

    func togglePasswordVisibility() {
        eyeButton.tap()
    }

    func clearEmail() {
        clearButton.tap()
    }
}
