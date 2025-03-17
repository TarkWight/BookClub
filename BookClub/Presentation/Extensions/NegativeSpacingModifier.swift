//
//  NegativeSpacingModifier.swift
//  BookClub
//
//  Created by Tark Wight on 17.03.2025.
//


import SwiftUI

enum SpacingType {
    case titleToSubtitle
    case subtitleLines
    
    var spacing: CGFloat {
        switch self {
        case .titleToSubtitle: return -20
        case .subtitleLines: return -80
        }
    }
}

struct NegativeSpacingModifier: ViewModifier {
    let font: (font: Font, size: CGFloat, lineHeight: CGFloat)
    let color: Color
    let spacingType: SpacingType
    
    func body(content: Content) -> some View {
        content
            .font(font.font)
            .foregroundColor(color)
            .padding(.bottom, spacingType.spacing)
    }
}

extension View {
    func applyNegativeSpacing(
        font: (font: Font, size: CGFloat, lineHeight: CGFloat),
        color: Color,
        spacingType: SpacingType
    ) -> some View {
        self.modifier(NegativeSpacingModifier(font: font, color: color, spacingType: spacingType))
    }
}
