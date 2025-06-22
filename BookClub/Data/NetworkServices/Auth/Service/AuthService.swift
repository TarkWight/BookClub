//
//  AuthService.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire
import Foundation

actor AuthService: AuthServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let keychainService: KeychainServiceProtocol

    init(
        networkClient: NetworkClientProtocol,
        keychainService: KeychainServiceProtocol
    ) {
        self.networkClient = networkClient
        self.keychainService = keychainService
    }

    func retrieveToken() async throws -> String {
        try await keychainService.retrieveToken()
    }

    func refreshToken(
        identifier: String? = nil,
        password: String? = nil
    ) async throws -> String {
        // Resolve identifier
        let finalIdentifier: String
        do {
            if let id = identifier {
                finalIdentifier = id
                try await keychainService.saveIdentifier(id)
            } else {
                finalIdentifier = try await keychainService.retrieveIdentifier()
            }
        } catch let err as KeychainError {
            throw mapKeychainError(err)
        }

        // Resolve password
        let finalPassword: String
        do {
            if let pw = password {
                finalPassword = pw
                try await keychainService.savePassword(pw)
            } else {
                finalPassword = try await keychainService.retrievePassword()
            }
        } catch let err as KeychainError {
            throw mapKeychainError(err)
        }

        // Perform login network request
        let resp: AuthResponse
        do {
            resp = try await networkClient.request(
                AuthConfig.login(
                    identifier: finalIdentifier,
                    password: finalPassword
                ),
                decoder: JSONDecoder()
            )
        } catch let netErr as NetworkError {
            throw LoginError.network(netErr)
        }

        // Save returned token
        let token = resp.jwt
        do {
            try await keychainService.saveToken(token)
        } catch let err as KeychainError {
            throw mapKeychainError(err)
        }

        return token
    }

    // MARK: - Helpers

    private func mapKeychainError(_ err: KeychainError) -> LoginError {
        switch err {
        case .tokenNotFound:       return .tokenNotFound
        case .identifierNotFound:  return .identifierNotFound
        case .passwordNotFound:    return .passwordNotFound
        case .unexpectedData:      return .unexpectedData
        case let .unhandledError(code):
            return .unhandledError(code)
        }
    }
}
