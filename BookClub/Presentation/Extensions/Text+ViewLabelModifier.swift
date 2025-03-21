//
//  Text+ViewLabelModifier.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct ViewLabelModifier: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontH1)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorSecondary)

    func body(content: Content) -> some View {
        content
            .font(font.font)
            .textCase(.uppercase)
            .foregroundColor(color)
    }
}

extension View {
    func applyTextLabelStyle() -> some View {
        self.modifier(ViewLabelModifier())
    }
}

// MARK: -
struct BookTitleStyle: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontH3)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)

    func body(content: Content) -> some View {
        content
            .font(font.font)
            .textCase(.uppercase)
            .foregroundColor(color)
            .frame(alignment: .trailing)
    }
}

extension View {
    func applyBookTitleStyle() -> some View {
        self.modifier(BookTitleStyle())
    }
}

// MARK: -

struct BookAuthorStyle: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontFootNote)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)

    func body(content: Content) -> some View {
        content
            .font(font.font)
            .frame(alignment: .trailing)
            .foregroundColor(color)
    }
}

extension View {
    func applyBookAuthorStyle() -> some View {
        self.modifier(BookAuthorStyle())
    }
}

// MARK: -

struct SubtitleLabelStyle: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontH2)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)
    
    func body(content: Content) -> some View {
        content
            .font(font.font)
            .foregroundColor(color)
            .textCase(.uppercase)
            .frame(alignment: .trailing)
            .foregroundColor(color)
    }
}

extension View {
    func applySubtitleLabelStyle() -> some View {
        self.modifier(SubtitleLabelStyle())
    }
}

// MARK: -

struct H2AccentDarkTitleStyle: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontH1)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)

    func body(content: Content) -> some View {
        content
            .font(font.font)
            .textCase(.uppercase)
            .foregroundColor(color)
    }
}

extension View {
    func applyH2AccentDarkTitleStyle() -> some View {
        self.modifier(H2AccentDarkTitleStyle())
    }
}

// MARK: -

struct BookDetailsAuthorStyle: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontBody)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)

    func body(content: Content) -> some View {
        content
            .font(font.font)
            .frame(alignment: .trailing)
            .foregroundColor(color)
    }
}

extension View {
    func applyBookDetailsAuthorStyle() -> some View {
        self.modifier(BookDetailsAuthorStyle())
    }
}

// MARK: -

struct GenreLabelStyle: ViewModifier {
    let font = UIKitAssets.setFont(for: UIKitAssets.fontBodySmall)
    let color = UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)

    func body(content: Content) -> some View {
        content
            .font(font.font)
            .foregroundColor(color)
    }
}

extension View {
    func applySmallBodyLabelStyle() -> some View {
        self.modifier(GenreLabelStyle())
    }
}

