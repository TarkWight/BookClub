//
//  AppFonts.swift
//  BookClub
//
//  Created by Tark Wight on 25.03.2025.
//

import SwiftUI

@MainActor
enum AppFonts {
    static let title = adaptiveFont(name: "Alumni Sans Bold", baseSize: 96, scaleFactor: 0.5)
    static let header1 = adaptiveFont(name: "Alumni Sans Bold", baseSize: 48, scaleFactor: 0.5)
    static let header2 = adaptiveFont(name: "Alumni Sans Bold", baseSize: 24, scaleFactor: 0.5)
    static let header3 = adaptiveFont(name: "Alumni Sans Bold", baseSize: 14, scaleFactor: 1)
    static let body = adaptiveFont(name: "Vela Sans", baseSize: 16, scaleFactor: 1)
    static let bodySmall = adaptiveFont(name: "Vela Sans", baseSize: 14, scaleFactor: 1)
    static let footnote = adaptiveFont(name: "Vela Sans", baseSize: 10, scaleFactor: 1)
    static let text = adaptiveFont(name: "Georgia", baseSize: 14, scaleFactor: 1)
    static let quote = adaptiveFont(name: "Georgia-Italic", baseSize: 16, scaleFactor: 1)

    private static func adaptiveFont(name: String, baseSize: CGFloat, scaleFactor: CGFloat) -> Font {
        let screenWidth = UIScreen.main.bounds.width
        let size = min(baseSize, screenWidth * scaleFactor)
        return Font.custom(name, size: size)
    }
}
