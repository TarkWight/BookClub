//
//  LoginReducer.swift
//  BookClub
//
//  Created by Tark Wight on 07.06.2025.
//

import Foundation

@MainActor
func loginReducer(
    state: inout LoginState,
    action: LoginAction,
    env: LoginEnvironment
) -> Effect<LoginAction> {
    switch action {

    // MARK: – Pure state mutations, no side-effects
    case let .emailChanged(email):
        state.email = email
        state.loginError = nil
        return .none

    case let .passwordChanged(password):
        state.password = password
        state.loginError = nil
        return .none

    case .togglePasswordVisibility:
        state.isPasswordVisible.toggle()
        return .none

    // MARK: – Trigger side-effect via an Effect
    case .didLoginButtonTapped:
        guard !state.isLoading else { return .none }
        state.isLoading = true
        state.loginError = nil

        let email = state.email
        let password = state.password

        return .task {
            do {
                _ = try await env.authService.refreshToken(
                    identifier: email,
                    password: password
                )
                return .loginSucceeded
            } catch let err as LoginError {
                return .loginFailed(err)
            } catch {
                return .loginFailed(.unexpectedData)
            }
        }

    // MARK: – Обработчики результатов
    case .loginSucceeded:
        state.isLoading = false
        return .none

    case let .loginFailed(error):
        state.isLoading = false
        state.loginError = error
        return .none

    case .dismissError:
        state.loginError = nil
        return .none
    }
}
