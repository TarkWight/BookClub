//
//  LoginAction.swift
//  BookClub
//
//  Created by Tark Wight on 05.06.2025.
//

import Foundation

enum LoginAction: Equatable {
    case emailChanged(String)
    case passwordChanged(String)
    case togglePasswordVisibility
    case didLoginButtonTapped
    case loginSucceeded
    case loginFailed(LoginError)
    case dismissError
}
