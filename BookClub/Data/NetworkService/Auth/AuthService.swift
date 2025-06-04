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

    func refreshToken() async throws -> String {
        let identifier = try await keychainService.retrieveIdentifier()

        let password = try await keychainService.retrievePassword()

        let bodyDict: [String: String] = [
            "identifier": identifier,
            "password": password
        ]

        let requestBody: Data
        do {
            requestBody = try JSONEncoder().encode(bodyDict)
        } catch {
            throw error
        }

        let authResponse: AuthResponse = try await networkService.request(
            with: AuthNetworkConfig.refresh(requestBody)
        )

        let newJwt = authResponse.accessToken

        try await keychainService.saveToken(newJwt)

        return newJwt
    }
}
