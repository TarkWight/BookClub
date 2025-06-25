//
//  AuthRetryManager.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import Foundation

actor AuthRetryManager {
    private let authService: AuthServiceProtocol
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func enqueue(_ completion: @Sendable @escaping (RetryResult) -> Void) {
        requestsToRetry.append(completion)
        guard !isRefreshing else { return }
        isRefreshing = true
        Task { await performRefresh() }
    }

    private func performRefresh() async {
        let completions = requestsToRetry
        requestsToRetry.removeAll()

        do {
            _ = try await authService.refreshToken(
                identifier: nil,
                password: nil
            )
            isRefreshing = false
            completions.forEach { $0(.retry) }
        } catch {
            isRefreshing = false
            completions.forEach { $0(.doNotRetryWithError(error)) }
        }
    }
}
