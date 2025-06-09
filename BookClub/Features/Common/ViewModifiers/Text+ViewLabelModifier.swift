//
//  Text+ViewLabelModifier.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

// MARK: - H1 Secondary Label Style
struct FontH1SecondaryModifier: ViewModifier {
    let font = AppFonts.header1
    let color = AppColors.secondary

    func body(content: Content) -> some View {
        content
            .font(font)
            .textCase(.uppercase)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontH1SecondaryStyle() -> some View {
        self.modifier(FontH1SecondaryModifier())
    }
}

// MARK: - Font H1 Accent Dark Style
struct FontH1AccentDarkModifier: ViewModifier {
    let font = AppFonts.header1
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .textCase(.uppercase)
            .foregroundColor(color)
    }
}

extension View {
    func applyH1AccentDarkTitleStyle() -> some View {
        self.modifier(FontH1AccentDarkModifier())
    }
}

// MARK: - Font H2 Accent Dark Style
struct FontH2AccentDarkModifier: ViewModifier {
    let font = AppFonts.header2
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .textCase(.uppercase)
            .frame(alignment: .trailing)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontH2AccentDarkStyle() -> some View {
        self.modifier(FontH2AccentDarkModifier())
    }
}

// MARK: - Font H3 Accent Dark Title Style
struct FontH3AccentDarkModifier: ViewModifier {
    let font = AppFonts.header3
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .textCase(.uppercase)
            .foregroundColor(color)
            .frame(alignment: .trailing)
    }
}

extension View {
    func applyFontH3AccentDarkStyle() -> some View {
        self.modifier(FontH3AccentDarkModifier())
    }
}

// MARK: - Font Foot Note Accent Dark Style
struct FontFootNoteAccentDarkModifier: ViewModifier {
    let font = AppFonts.footnote
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .frame(alignment: .trailing)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontFootNoteStyle() -> some View {
        self.modifier(FontFootNoteAccentDarkModifier())
    }
}

// MARK: - Font Body Accent Dark Style
struct FontBodyAccentDarkModifier: ViewModifier {
    let font = AppFonts.body
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .frame(alignment: .trailing)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontBodyAccentDarkStyle() -> some View {
        self.modifier(FontBodyAccentDarkModifier())
    }
}

// MARK: - Font Body Small Accent Dark Style
struct FontBodySmallAccentDarkModifier: ViewModifier {
    let font = AppFonts.bodySmall
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontBodySmallAccentDarkStyle() -> some View {
        self.modifier(FontBodySmallAccentDarkModifier())
    }
}

// MARK: - Font Quote Accent Dark Style
struct FontQuoteAccentDarkModifier: ViewModifier {
    let font = AppFonts.quote
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontQuoteAccentDarkStyle() -> some View {
        self.modifier(FontQuoteAccentDarkModifier())
    }
}

// MARK: - Font Text Accent Dark Style
struct FontTextAccentDarkModifier: ViewModifier {
    let font = AppFonts.text
    let color = AppColors.accentDark

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }
}

extension View {
    func applyFontTextAccentDarkStyle() -> some View {
        self.modifier(FontTextAccentDarkModifier())
    }
}
