//
//  NoveltyBook.swift
//  BookClub
//
//  Created by Tark Wight on 25.03.2025.
//

import Foundation

struct NoveltyBook: Identifiable {
    let id: UUID = .init()
    let imageName: String
    let title: String
    let description: String
}
