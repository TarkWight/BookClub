//
//  AuthResponse.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

struct AuthResponse: Codable, Sendable {
    let jwt: String
}
