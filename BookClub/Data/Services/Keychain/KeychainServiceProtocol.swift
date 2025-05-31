//
//  KeychainServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 31.05.2025.
//

import Foundation

protocol KeychainServiceProtocol {
    func saveToken(_ token: String) async throws
    func retrieveToken() async throws -> String
    func deleteToken() async throws
}
