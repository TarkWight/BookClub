//
//  ReadingProgressNetworkItem.swift
//  BookClub
//
//  Created by Tark Wight on 30.06.2025.
//

import Foundation

struct ReadingProgressNetworkItem: Codable {
  let id: Int64
  let documentId: String
  let progress: Double
}
