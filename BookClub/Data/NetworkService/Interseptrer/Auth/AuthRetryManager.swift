//
//  AuthRetryManager.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation
import Alamofire

actor AuthRetryManager {
    private let authService: AuthServiceProtocol

    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func enqueue(_ completion: @escaping @Sendable (RetryResult) -> Void) {
        requestsToRetry.append(completion)

        if !isRefreshing {
            isRefreshing = true

            Task {
                await performRefresh()
            }
        }
    }

    private func performRefresh() async {
        do {
            _ = try await authService.refreshToken()
            let completions = requestsToRetry
            requestsToRetry.removeAll()
            isRefreshing = false

            for compl in completions {
                compl(.retry)
            }
        } catch {
            let completions = requestsToRetry
            requestsToRetry.removeAll()
            isRefreshing = false

            for compl in completions {
                compl(.doNotRetryWithError(error))
            }
        }
    }
}
