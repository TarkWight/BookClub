//
//  ReadingSessionProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 29.06.2025.
//

import Foundation

protocol ReadingSessionProtocol: Sendable {
    func startReading(documentId: String, chapterOrder: Int) async

    func onChunkAppear(_ chunk: TextChunk) async

    func toggleAutoScroll() async

    func userDidScroll() async

    func goToChapter(order: Int) async
}
