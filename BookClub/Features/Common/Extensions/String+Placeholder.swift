//
//  String+Placeholder.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

extension String {
    static func placeholder(length: Int) -> String {
        return String(Array(repeating: "X", count: length))
    }
}
