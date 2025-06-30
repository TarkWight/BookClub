//
//  RecentSearchServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import Foundation

protocol RecentSearchServiceProtocol: Sendable {
    func load() async throws -> [String]
    func add(_ query: String) async throws
    func remove(_ query: String) async throws
    func removeAll() async throws
}
