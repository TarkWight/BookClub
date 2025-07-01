//
//  AuthAdapter.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import Foundation

final class AuthAdapter: RequestAdapter {
    private let keychainService: KeychainServiceProtocol

    init(keychainService: KeychainServiceProtocol) {
        self.keychainService = keychainService
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        Task {
            do {
                let token = try await keychainService.retrieveToken()
                request.headers.add(
                    name: "Authorization",
                    value: "Bearer \(token)"
                )
                completion(.success(request))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
