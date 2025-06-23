//
//  HasPlaceholder.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

protocol HasPlaceholder {
    static func placeholder(id: String) -> Self
}

extension Array where Element: HasPlaceholder {
    static func placeholders(count: Int) -> [Element] {
        (0..<count).map { .placeholder(id: "\($0)") }
    }
}
