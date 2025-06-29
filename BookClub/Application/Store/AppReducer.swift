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
        // First, run the MainTab reducer to update nested state
        let effect = mainTabReducer(
            state: &state.mainTab,
            action: tabAction,
            env: env.mainTabEnv
        )
        .map(AppAction.mainTab)

        // Then handle navigation based on the specific MainTabAction
        switch tabAction {
        case .library(.didSelectBook):
            state.path.append(.bookDetails)
        case .bookDetails(.configure):
            // the configure action already updated state, but navigation also follows
            state.path.append(.bookDetails)
        case .bookDetails(.openChapter):
            state.path.removeLast()
        case .bookDetails(.startReadingTapped), .readSelected:
            state.path.append(.reader)
        case .logoutTapped:
            // handle logout navigation if needed
            break
        default:
            break
        }
        return effect
    }
}
