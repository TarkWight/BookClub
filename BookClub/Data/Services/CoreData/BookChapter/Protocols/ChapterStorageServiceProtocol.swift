//
//  ChapterStorageServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

protocol ChapterStorageServiceProtocol: Sendable {
    func setStatus(
        chapterOrder: Int,
        inBook documentId: String,
        to newStatus: ChapterStatus
    ) async throws

    func markAllPreviousAndCurrentCompleted(
        upTo order: Int,
        inBook documentId: String
    ) async throws

    func markAllFromAndAfterNotStarted(
        from order: Int,
        inBook documentId: String
    ) async throws

    func computeProgress(
        forBook documentId: String
    ) async throws -> Double

    func fetchChapters(
        forDocumentId documentId: String
    ) async throws -> [ChapterDTO]

    func fetchChapterSummaries(
        forDocumentId documentId: String
    ) async throws -> [ChapterSummary]

    func saveFullChapters(
        _ chapters: [ChapterDTO],
        forDocumentId documentId: String
    ) async throws
}
