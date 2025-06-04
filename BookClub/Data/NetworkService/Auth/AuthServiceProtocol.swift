//
//  AuthServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

protocol AuthServiceProtocol: Sendable {
    func refreshToken() async throws -> String
}
