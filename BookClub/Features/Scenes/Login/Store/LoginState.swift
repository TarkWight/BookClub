//
//  AuthState.swift
//  BookClub
//
//  Created by Tark Wight on 05.06.2025.
//

import Foundation

struct LoginState: Equatable, Sendable {
    var email: String = ""
    var password: String = ""
    var isPasswordVisible: Bool = false

    var isLoading: Bool = false

    var loginError: LoginError? = nil

    var isFormValid: Bool {
        email.isEmpty || password.isEmpty
    }
}
