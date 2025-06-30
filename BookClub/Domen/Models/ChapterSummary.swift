//
//  ChapterSummary.swift
//  BookClub
//
//  Created by Tark Wight on 28.06.2025.
//

import Foundation

struct ChapterSummary: Identifiable, Equatable {
    let id: Int64
    let order: Int
    let title: String
    let status: ChapterStatus
}
