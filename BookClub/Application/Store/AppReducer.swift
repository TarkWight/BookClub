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
        return .task(id: UUID()) {
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

    case .pathChanged(let path):
        state.path = path
        return .none

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

    case .mainTab(let tabAction):
        let effect = mainTabReducer(
            state: &state.mainTab,
            action: tabAction,
            env: env.mainTabEnv
        )
        .map(AppAction.mainTab)

        switch tabAction {
        case .library(.didSelectBook):
            state.path.append(.bookDetails)
        case .bookDetails(.backButtonTapped):
            state.path.removeLast()
        case .bookDetails(.startReadingTapped), .readSelected:
            state.path.append(.reader)
        case .logoutTapped:
            break
        default:
            break
        }
        return effect
    }
}
