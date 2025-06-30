//
//  AuthorStorageServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import Foundation

protocol AuthorStorageServiceProtocol: Sendable {
    func save(_ items: [AuthorItem]) async throws
    func fetchAll() async throws -> [AuthorItem]
    func deleteAll() async throws
}
