//
//  LoginReducerTests.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import XCTest

@testable import BookClub

@MainActor
final class LoginReducerTests: XCTestCase {

    struct DummyAuth: AuthServiceProtocol {
        var shouldSucceedRefresh: Bool
        func retrieveToken() async throws -> String { fatalError() }
        func refreshToken(identifier: String?, password: String?) async throws
            -> String
        {
            if shouldSucceedRefresh {
                return "ok"
            } else {
                throw LoginError.invalidCredentials
            }
        }
    }

    var envSuccess: LoginEnvironment!
    var envFailure: LoginEnvironment!

    override func setUp() {
        super.setUp()
        envSuccess = LoginEnvironment(
            authService: DummyAuth(shouldSucceedRefresh: true)
        )
        envFailure = LoginEnvironment(
            authService: DummyAuth(shouldSucceedRefresh: false)
        )
    }

    func testEmailChanged() async {
        var state = LoginState()
        let effect = loginReducer(
            state: &state,
            action: .emailChanged("alice"),
            env: envSuccess
        )
        XCTAssertEqual(state.email, "alice")
        XCTAssertNil(state.loginError)
        XCTAssertFalse(state.isLoading)
        XCTAssertTrue(effect.isNone)
    }

    func testPasswordChanged() async {
        var state = LoginState()
        let effect = loginReducer(
            state: &state,
            action: .passwordChanged("pwd"),
            env: envSuccess
        )
        XCTAssertEqual(state.password, "pwd")
        XCTAssertNil(state.loginError)
        XCTAssertTrue(effect.isNone)
    }

    func testTogglePasswordVisibility() async {
        var state = LoginState(isPasswordVisible: false)
        let effect = loginReducer(
            state: &state,
            action: .togglePasswordVisibility,
            env: envSuccess
        )
        XCTAssertTrue(state.isPasswordVisible)
        XCTAssertTrue(effect.isNone)
    }

    func testDismissError() async {
        var state = LoginState(loginError: .invalidCredentials)
        let effect = loginReducer(
            state: &state,
            action: .dismissError,
            env: envSuccess
        )
        XCTAssertNil(state.loginError)
        XCTAssertTrue(effect.isNone)
    }

    func testLoginButtonTappedSetsLoading() async {
        var state = LoginState(email: "e", password: "p", isLoading: false)
        let effect = loginReducer(
            state: &state,
            action: .didLoginButtonTapped,
            env: envSuccess
        )
        XCTAssertTrue(state.isLoading)
        XCTAssertNil(state.loginError)
        // Effect должно быть .task
        XCTAssertTrue(effect.isTask)
    }

    func testLoginButtonTappedWhenLoadingDoesNothing() async {
        var state = LoginState(isLoading: true)
        let effect = loginReducer(
            state: &state,
            action: .didLoginButtonTapped,
            env: envSuccess
        )
        XCTAssertTrue(state.isLoading)
        XCTAssertTrue(effect.isNone)
    }

    func testLoginSucceeded() async {
        var state = LoginState(isLoading: true)
        let effect = loginReducer(
            state: &state,
            action: .loginSucceeded,
            env: envSuccess
        )
        XCTAssertFalse(state.isLoading)
        XCTAssertTrue(effect.isNone)
    }

    func testLoginFailed() async {
        var state = LoginState(isLoading: true, loginError: nil)
        let effect = loginReducer(
            state: &state,
            action: .loginFailed(.invalidCredentials),
            env: envSuccess
        )
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.loginError, .invalidCredentials)
        XCTAssertTrue(effect.isNone)
    }

    func testDidLoginButtonTappedEffectSuccess() async throws {
        var state = LoginState(email: "e", password: "p", isLoading: false)

        let taskEffect = loginReducer(
            state: &state,
            action: .didLoginButtonTapped,
            env: envSuccess
        )

        let nextAction = await taskEffect.run()
        XCTAssertEqual(nextAction, .loginSucceeded)
    }

    func testDidLoginButtonTappedEffectFailure() async throws {
        var state = LoginState(email: "e", password: "p", isLoading: false)
        let taskEffect = loginReducer(
            state: &state,
            action: .didLoginButtonTapped,
            env: envFailure
        )
        let nextAction = await taskEffect.run()
        XCTAssertEqual(nextAction, .loginFailed(.invalidCredentials))
    }

}
