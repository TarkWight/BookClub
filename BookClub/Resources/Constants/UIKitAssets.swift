//
//  UIKitAssets.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

enum UIKitAssets {
    
    // MARK: - Icons
    static let imageEyeOn = "Eye On"
    static let imageEyeOff = "Eye Off"
    static let imageClose = "Close"
    static let imageLibrary = "Library"
    static let imageSearch = "Search"
    static let imageBookmarks = "Bookmarks"
    static let imageArrowLeft = "Arrow Left"
    static let imageContents = "Contents"
    static let imagePlay = "Play"
    static let imagePause = "Pause"
    static let imageSettings = "Settings"
    static let imagePrevious = "Previous"
    static let imageNext = "Next"
    static let imageHistory = "History"
    static let imageLogOut = "Log Out"
    static let imageRead = "Read"
    static let imageReadingNow = "Reading Now"
    
    static func setImage(for icon: String) -> Image {
        return Image(icon)
    }
    
    // MARK: - Colors
    static let colorAccentDark = "Accent Dark"
    static let colorAccentMedium = "Accent Medium"
    static let colorAccentLight = "Accent Light"
    static let colorSecondary = "AppSecondary"
    static let colorBackground = "AppBackground"
    static let colorBlack = "AppBlack"
    static let colorWhite = "AppWhite"
    
    static func setColor(for name: String) -> Color {
        return Color(name)
    }
    
    // MARK: - Fonts
    static let fontTitle = ("Alumni Sans Bold", CGFloat(96), CGFloat(0.8))
    static let fontH1 = ("Alumni Sans Bold", CGFloat(48), CGFloat(0.6))
    static let fontH2 = ("Alumni Sans Bold", CGFloat(24), CGFloat(0.5))
    static let fontBody = ("Vela Sans", CGFloat(16), CGFloat(1))
    static let fontBodySmall = ("Vela Sans", CGFloat(14), CGFloat(1))
    static let fontFootNote = ("Vela Sans", CGFloat(10), CGFloat(1))
    static let fontText = ("Georgia", CGFloat(14), CGFloat(1))
    static let fontQuote = ("Georgia", CGFloat(16), CGFloat(1))
    
    @MainActor static func setFont(_ font: (name: String, baseSize: CGFloat, scaleFactor: CGFloat)) -> (font: Font, size: CGFloat) {
        let adaptiveSize = min(font.baseSize, UIScreen.main.bounds.width * font.scaleFactor)
        return (Font.custom(font.name, size: adaptiveSize), adaptiveSize)
    }
}
