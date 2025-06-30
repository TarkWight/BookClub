//
//  AuthRetrier.swift
//  BookClub
//
//  Created by Tark Wight on 02.06.2025.
//

import Alamofire
import Foundation

final class AuthRetrier: RequestRetrier {
    #if DEBUG
        let retryManager: AuthRetryManager
    #else
        private let retryManager: AuthRetryManager
    #endif

    init(authService: AuthServiceProtocol) {
        self.retryManager = AuthRetryManager(authService: authService)
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @Sendable @escaping (RetryResult) -> Void
    ) {
        let statusCode = (request.task?.response as? HTTPURLResponse)?
            .statusCode
        if shouldRetry(statusCode: statusCode) {
            Task { await retryManager.enqueue(completion) }
        } else {
            completion(.doNotRetry)
        }
    }

    func shouldRetry(statusCode: Int?) -> Bool {
        statusCode == 401
    }
}

#if DEBUG
    extension AuthRetrier {
        /// For tests: simulate retry without an actual `Request`
        func simulateRetry(
            statusCode: Int?,
            completion: @Sendable @escaping (RetryResult) -> Void
        ) {
            if shouldRetry(statusCode: statusCode) {
                Task { await retryManager.enqueue(completion) }
            } else {
                completion(.doNotRetry)
            }
        }
    }
#endif
