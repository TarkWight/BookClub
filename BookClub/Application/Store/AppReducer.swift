//
//  AppReducer.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

@MainActor
func appReducer(
    state: inout AppState,
    action: AppAction,
    env: AppEnvironment
) -> Effect<AppAction> {
    switch action {
    case .appStarted:
        return .task {
            do {
                _ = try await env.authService.retrieveToken()
                return .authStatusChanged(.authenticated)
            } catch {
                return .authStatusChanged(.unauthenticated)
            }
        }

    case .authStatusChanged(let newStatus):
        state.authStatus = newStatus
        state.path = []
        return .none

    // MARK: — navigation
    case let .pathChanged(path):
        state.path = path
        return .none

    // MARK: — login flow
    case .login(.loginSucceeded):
        state.path = [.mainTab]
        return .none

    case .login(let loginAction):
        return loginReducer(
            state: &state.login,
            action: loginAction,
            env: env.loginEnv
        )
        .map(AppAction.login)

    // MARK: — mainTab flow
    case .mainTab(let action):
        return mainTabReducer(
            state: &state.mainTab,
            action: action,
            env: env.mainTabEnv
        )
        .map(AppAction.mainTab)
    }
}
