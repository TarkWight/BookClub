//
//  AuthServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

protocol AuthServiceProtocol: Sendable {
    func refreshToken(identifier: String?, password: String?) async throws -> String
}
