//
//  AppEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

struct AppEnvironment {
    let authService: AuthServiceProtocol

    var loginEnv: LoginEnvironment {
        LoginEnvironment(authService: authService)
    }
}
