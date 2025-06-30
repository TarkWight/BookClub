//
//  MockAuthService.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation
@testable import BookClub

@MainActor
final class MockAuthService: AuthServiceProtocol {
    /// Control whether `retrieveToken()` should succeed or throw
    var shouldSucceedRetrieve = true
    /// Control whether `refreshToken(...)` should succeed or throw
    var shouldSucceedRefresh = true

    private(set) var retrieveTokenCalled = false
    private(set) var retrieveTokenCallCount = 0

    private(set) var refreshTokenCalled = false
    private(set) var refreshTokenCallCount = 0

    func retrieveToken() async throws -> String {
        retrieveTokenCallCount += 1
        retrieveTokenCalled = true
        if shouldSucceedRetrieve {
            return "stub-token"
        } else {
            throw URLError(.notConnectedToInternet)
        }
    }

    func refreshToken(identifier: String?, password: String?) async throws -> String {
        refreshTokenCallCount += 1
        refreshTokenCalled = true
        if shouldSucceedRefresh {
            return "new-token"
        } else {
            throw URLError(.notConnectedToInternet)
        }
    }
}
