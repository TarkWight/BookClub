//
//  ServerErrorRetrier.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation
import Alamofire

final class ServerErrorRetrier: RequestRetrier {
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        completion(makeRetryResult(from: error))
    }

    func makeRetryResult(from error: Error) -> RetryResult {
        if let afError = error as? AFError,
           case .responseValidationFailed(let reason) = afError,
           case let .unacceptableStatusCode(statusCode) = reason,
           (500...599).contains(statusCode) {
            return .retryWithDelay(1.0)
        } else {
            return .doNotRetry
        }
    }
}
