//
//  TokenProviderProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 22.06.2025.
//

import Foundation

public protocol TokenProvider: Sendable {
    var token: String? { get }
}
