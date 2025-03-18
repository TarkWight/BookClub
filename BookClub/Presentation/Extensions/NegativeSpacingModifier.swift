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
    
    var baseSpacing: CGFloat {
        switch self {
        case .titleToSubtitle: return -20
        case .subtitleLines: return -80
        }
    }
    
    func adaptiveSpacing(screenWidth: CGFloat) -> CGFloat {
        let scaleFactor: CGFloat
        switch screenWidth {
        case 0...375:
            scaleFactor = 0.5
        default:
            scaleFactor = 1.0
        }
        
        // TODO: - Remove print statements
//        print("baseSpacing: \(baseSpacing)")
//        print("screenWidth: \(screenWidth)")
//        print("scaleFactor: \(scaleFactor)")
//        print("result: \(baseSpacing * scaleFactor)")
        return baseSpacing * scaleFactor
    }
}

struct NegativeSpacingModifier: ViewModifier {
    let font: (font: Font, size: CGFloat)
    let color: Color
    let spacingType: SpacingType
    
    func body(content: Content) -> some View {
        let screenWidth = UIScreen.main.bounds.width
        let adaptiveSpacing = spacingType.adaptiveSpacing(screenWidth: screenWidth)
        
        return content
            .font(font.font)
            .foregroundColor(color)
            .padding(.bottom, adaptiveSpacing)
    }
}

extension View {
    func applyNegativeSpacing(
        font: (font: Font, size: CGFloat),
        color: Color,
        spacingType: SpacingType
    ) -> some View {
        self.modifier(NegativeSpacingModifier(font: font, color: color, spacingType: spacingType))
    }
}
