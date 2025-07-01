//
//  KeychainServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 31.05.2025.
//

import Foundation

protocol KeychainServiceProtocol: Sendable {
    func saveToken(_ token: String) async throws
    func retrieveToken() async throws -> String
    func deleteToken() async throws

    func saveIdentifier(_ identifier: String) async throws
    func retrieveIdentifier() async throws -> String
    func deleteIdentifier() async throws

    func savePassword(_ password: String) async throws
    func retrievePassword() async throws -> String
    func deletePassword() async throws

    func deleteAllCredentials() async throws
}
