//
//  Text+ViewModidier.swift
//  BookClub
//
//  Created by Tark Wight on 30.03.2025.
//

import SwiftUI

// MARK: - FontStyle Enum

enum FontStyle {
    case title
    case header1
    case header2
    case header3
    case footnote
    case body
    case bodySmall
    case quote
    case text
}

// MARK: - FontModifierConfiguration Struct

struct FontModifierConfiguration {
    let fontName: String
    let fontSize: CGFloat
    let color: Color
    let uppercased: Bool
    let alignment: Alignment

    init(style: FontStyle) {
        switch style {
        case .title:
            self.fontName = AppFonts.title
            self.fontSize = 96
            self.color = AppColors.secondary
            self.uppercased = true
            self.alignment = .leading

        case .header1:
            self.fontName = AppFonts.header1
            self.fontSize = 48
            self.color = AppColors.secondary
            self.uppercased = true
            self.alignment = .leading

        case .header2:
            self.fontName = AppFonts.header2
            self.fontSize = 24
            self.color = AppColors.accentDark
            self.uppercased = true
            self.alignment = .trailing

        case .header3:
            self.fontName = AppFonts.header3
            self.fontSize = 14
            self.color = AppColors.accentDark
            self.uppercased = true
            self.alignment = .trailing

        case .footnote:
            self.fontName = AppFonts.footnote
            self.fontSize = 10
            self.color = AppColors.accentDark
            self.uppercased = false
            self.alignment = .trailing

        case .body:
            self.fontName = AppFonts.body
            self.fontSize = 16
            self.color = AppColors.accentDark
            self.uppercased = false
            self.alignment = .trailing

        case .bodySmall:
            self.fontName = AppFonts.bodySmall
            self.fontSize = 14
            self.color = AppColors.accentDark
            self.uppercased = false
            self.alignment = .leading

        case .quote:
            self.fontName = AppFonts.quote
            self.fontSize = 16
            self.color = AppColors.accentDark
            self.uppercased = false
            self.alignment = .leading

        case .text:
            self.fontName = AppFonts.text
            self.fontSize = 14
            self.color = AppColors.accentDark
            self.uppercased = false
            self.alignment = .leading
        }
    }

    init(fontName: String, fontSize: CGFloat, color: Color, uppercased: Bool = false, alignment: Alignment = .leading) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.color = color
        self.uppercased = uppercased
        self.alignment = alignment
    }
}

// MARK: - Dynamic Configuration Methods

extension FontModifierConfiguration {

    func withFontSize(_ newSize: CGFloat) -> FontModifierConfiguration {
        return FontModifierConfiguration(
            fontName: self.fontName,
            fontSize: newSize,
            color: self.color,
            uppercased: self.uppercased,
            alignment: self.alignment
        )
    }

    func withColor(_ newColor: Color) -> FontModifierConfiguration {
        return FontModifierConfiguration(
            fontName: self.fontName,
            fontSize: self.fontSize,
            color: newColor,
            uppercased: self.uppercased,
            alignment: self.alignment
        )
    }

    func withUppercased(_ isUppercased: Bool) -> FontModifierConfiguration {
        return FontModifierConfiguration(
            fontName: self.fontName,
            fontSize: self.fontSize,
            color: self.color,
            uppercased: isUppercased,
            alignment: self.alignment
        )
    }

    func withAlignment(_ newAlignment: Alignment) -> FontModifierConfiguration {
        return FontModifierConfiguration(
            fontName: self.fontName,
            fontSize: self.fontSize,
            color: self.color,
            uppercased: self.uppercased,
            alignment: newAlignment
        )
    }
}

// MARK: - Universal FontModifier

struct FontModifier: ViewModifier {
    let configuration: FontModifierConfiguration

    func body(content: Content) -> some View {
        content
            .font(.custom(configuration.fontName, size: configuration.fontSize))
            .foregroundColor(configuration.color)
            .textCase(configuration.uppercased ? .uppercase : .none)
            .frame(maxWidth: .infinity, alignment: configuration.alignment.toHorizontalAlignment())
    }
}

private extension Alignment {
    func toHorizontalAlignment() -> Alignment {
        switch self {
        case .trailing:
            return .trailing
        case .center:
            return .center
        default:
            return .leading
        }
    }
}

// MARK: - View Extension for Applying Modifiers

extension View {
    func applyFontStyle(
        _ style: FontStyle,
        fontSize: CGFloat? = nil,
        color: Color? = nil,
        uppercased: Bool? = nil,
        alignment: Alignment? = nil
    ) -> some View {
        var configuration = FontModifierConfiguration(style: style)

        if let fontSize = fontSize {
            configuration = configuration.withFontSize(fontSize)
        }

        if let color = color {
            configuration = configuration.withColor(color)
        }

        if let uppercased = uppercased {
            configuration = configuration.withUppercased(uppercased)
        }

        if let alignment = alignment {
            configuration = configuration.withAlignment(alignment)
        }

        return self.modifier(FontModifier(configuration: configuration))
    }

    func applyCustomFontStyle(configuration: FontModifierConfiguration) -> some View {
        self.modifier(FontModifier(configuration: configuration))
    }
}
