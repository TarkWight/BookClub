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
    var shouldSucceed = true
    private(set) var refreshTokenCalled = false
    private(set) var refreshTokenCallCount = 0

    func refreshToken(identifier: String?, password: String?) async throws -> String {
        refreshTokenCallCount += 1
        refreshTokenCalled = true
        if shouldSucceed {
            return "new-token"
        } else {
            throw URLError(.notConnectedToInternet)
        }
    }
}
