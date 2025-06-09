//
//  AuthService.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

actor AuthService: AuthServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let keychainService: KeychainServiceProtocol

    init(
        networkService: NetworkServiceProtocol,
        keychainService: KeychainServiceProtocol
    ) {
        self.networkService = networkService
        self.keychainService = keychainService
    }

    func refreshToken(
        identifier: String? = nil,
        password: String? = nil
    ) async throws -> String {
        let finalIdentifier: String
        do {
            if let identifier {
                finalIdentifier = identifier
                try await keychainService.saveIdentifier(identifier)
            } else {
                finalIdentifier = try await keychainService.retrieveIdentifier()
            }
        } catch let error as KeychainError {
            switch error {
            case .identifierNotFound:
                throw LoginError.identifierNotFound
            case .tokenNotFound:
                throw LoginError.tokenNotFound
            case .unexpectedData:
                throw LoginError.unexpectedData
            case let .unhandledError(code):
                throw LoginError.unhandledError(code)
            case .passwordNotFound:
                throw LoginError.passwordNotFound
            }
        }

        let finalPassword: String
        do {
            if let password {
                finalPassword = password
                try await keychainService.savePassword(password)
            } else {
                finalPassword = try await keychainService.retrievePassword()
            }
        } catch let error as KeychainError {
            switch error {
            case .passwordNotFound:
                throw LoginError.passwordNotFound
            case .identifierNotFound:
                throw LoginError.identifierNotFound
            case .unexpectedData:
                throw LoginError.unexpectedData
            case let .unhandledError(code):
                throw LoginError.unhandledError(code)
            case .tokenNotFound:
                throw LoginError.tokenNotFound
            }
        }

        let requestBody = try JSONEncoder().encode([
            "identifier": finalIdentifier,
            "password": finalPassword
        ])

        let newJwt: String
        do {
            let authResponse: AuthResponse = try await networkService.request(
                with: AuthNetworkConfig.refresh(requestBody)
            )
            newJwt = authResponse.accessToken
        } catch let netErr as NetworkError {
            throw LoginError.network(netErr)
        } catch {
            throw LoginError.unexpectedData
        }

        do {
            try await keychainService.saveToken(newJwt)
        } catch let error as KeychainError {
            switch error {
            case .tokenNotFound:
                throw LoginError.tokenNotFound
            case .unexpectedData:
                throw LoginError.unexpectedData
            case let .unhandledError(code):
                throw LoginError.unhandledError(code)
            case .identifierNotFound:
                throw LoginError.identifierNotFound
            case .passwordNotFound:
                throw LoginError.passwordNotFound
            }
        }

        return newJwt
    }
}
