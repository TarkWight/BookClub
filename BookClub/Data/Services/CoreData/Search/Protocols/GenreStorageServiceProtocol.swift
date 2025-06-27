//
//  GenreStorageServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import Foundation

protocol GenreStorageServiceProtocol: Sendable {
    func save(_ items: [GenreItem]) async throws
    func fetchAll() async throws -> [GenreItem]
    func deleteAll() async throws
}
