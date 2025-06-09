//
//  AuthResponse.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

struct AuthResponse: Codable, Sendable {
    let accessToken: String

    private enum CodingKeys: String, CodingKey {
        case accessToken = "jwt"
    }
}
