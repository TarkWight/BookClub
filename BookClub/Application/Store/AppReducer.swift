//
//  AppReducer.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

func appReducer(
    state: inout AppState,
    action: AppAction,
    env: AppEnvironment
) -> Effect<AppAction> {
    switch action {
        // MARK: — navigation
    case let .pathChanged(path):
        state.path = path
        return .none

        // MARK: — login flow
    case .login(let loginAction):
        return loginReducer(
            state: &state.login,
            action: loginAction,
            env: env.loginEnv
        )
        .map(AppAction.login)
    }
}
