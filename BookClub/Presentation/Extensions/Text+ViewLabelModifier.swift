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

// MARK: - BookDetailsView
struct BookDetailsTitleStyle: ViewModifier {
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
    func applyBookDetailsTitleStyle() -> some View {
        self.modifier(BookDetailsTitleStyle())
    }
}

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

