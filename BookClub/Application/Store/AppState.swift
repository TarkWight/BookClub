//
//  AppState.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

enum AuthStatus: Equatable {
    case unknown
    case unauthenticated
    case authenticated
}

struct AppState: Equatable {
    var authStatus: AuthStatus = .unauthenticated
    var path: [AppRoute] = []
    var login: LoginState = .init()
    var mainTab: MainTabState = .init()
}
