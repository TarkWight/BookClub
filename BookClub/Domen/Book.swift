//
//  Book.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

struct Book: Equatable, Sendable {
    let id: Int64
    let documentId: String
    let title: String
    let coverURL: URL?
    let illustrationURL: URL?
    let isNew: Bool
}
