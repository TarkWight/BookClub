//
//  ReadingProgressNetworkItem.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

struct ReadingProgressNetworkItem: Codable {
    let documentId: String
    let value: Double
    let chapterId: Int64
}
