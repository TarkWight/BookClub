//
//  AppActions.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

enum AppAction: Equatable {
    case pathChanged([AppRoute])

    case appStarted
    case authStatusChanged(AuthStatus)

    case login(LoginAction)
    case mainTab(MainTabAction)
}
