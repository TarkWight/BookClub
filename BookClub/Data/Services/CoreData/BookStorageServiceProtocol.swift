//
//  BookStorageServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

protocol BookStorageServiceProtocol {
    func save(_ books: [Book]) async throws
    func fetch(isNew: Bool?) async throws -> [Book]
    func fetch(byID id: Int64) async throws -> Book?
    func fetch(byDocumentId documentId: String) async throws -> Book?
    func deleteAll() async throws
}
