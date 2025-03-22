//
//  UIKitAssets.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

enum UIKitAssets {
    
    // MARK: - Icons
    enum Icon: String {
        case eyeOn = "Eye On"
        case eyeOff = "Eye Off"
        case close = "Close"
        case library = "Library"
        case search = "Search"
        case bookmarks = "Bookmarks"
        case arrowLeft = "Arrow Left"
        case contents = "Contents"
        case play = "Play"
        case pause = "Pause"
        case settings = "Settings"
        case previous = "Previous"
        case next = "Next"
        case history = "History"
        case logOut = "Log Out"
        case read = "Read"
        case readingNow = "Reading Now"
    }
    
    static func setImage(for icon: Icon) -> Image {
        Image(icon.rawValue)
    }

    // MARK: - Colors
    enum ColorName: String {
        case accentDark = "Accent Dark"
        case accentMedium = "Accent Medium"
        case accentLight = "Accent Light"
        case secondary = "AppSecondary"
        case background = "AppBackground"
        case black = "AppBlack"
        case white = "AppWhite"
    }

    static func setColor(for name: ColorName) -> Color {
        Color(name.rawValue)
    }

    // MARK: - Fonts
    enum FontName {
        case title
        case h1
        case h2
        case h3
        case body
        case bodySmall
        case footnote
        case text
        case quote

        var fontInfo: (name: String, baseSize: CGFloat, scaleFactor: CGFloat) {
            switch self {
            case .title: return ("Alumni Sans Bold", 96, 0.5)
            case .h1: return ("Alumni Sans Bold", 48, 0.5)
            case .h2: return ("Alumni Sans Bold", 24, 0.5)
            case .h3: return ("Alumni Sans Bold", 14, 1)
            case .body: return ("Vela Sans", 16, 1)
            case .bodySmall: return ("Vela Sans", 14, 1)
            case .footnote: return ("Vela Sans", 10, 1)
            case .text: return ("Georgia", 14, 1)
            case .quote: return ("Georgia-Italic", 16, 1)
            }
        }
    }

    @MainActor
    static func setFont(for font: FontName) -> (font: Font, size: CGFloat) {
        let info = font.fontInfo
        let adaptiveSize = min(info.baseSize, UIScreen.main.bounds.width * info.scaleFactor)
        return (Font.custom(info.name, size: adaptiveSize), adaptiveSize)
    }
}
