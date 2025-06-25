//
//  ServerErrorRetrier.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import Foundation

final class ServerErrorRetrier: RequestRetrier {
    private let retryLimit: Int

    init(retryLimit: Int = 3) {
        self.retryLimit = retryLimit
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard request.retryCount < retryLimit else {
            completion(.doNotRetry)
            return
        }
        if case let afErr as AFError = error,
            case let .responseValidationFailed(.unacceptableStatusCode(code)) =
                afErr,
            (500...599).contains(code)
        {
            completion(.retry)
            return
        }
        if let urlErr = error as? URLError,
            [.timedOut, .notConnectedToInternet, .networkConnectionLost]
                .contains(urlErr.code)
        {
            completion(.retry)
            return
        }
        completion(.doNotRetry)
    }
}
