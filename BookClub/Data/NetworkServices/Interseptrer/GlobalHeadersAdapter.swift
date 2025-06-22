//
//  GlobalHeadersAdapter.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import Foundation

final class GlobalHeadersAdapter: RequestAdapter {
    private let tokenProvider: TokenProvider
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        if let token = tokenProvider.token {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }
        completion(.success(request))
    }
}
