//
//  Image+Gradient.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct BookGradientMask: ViewModifier {
    var colors: [Color] = [.white.opacity(0.0), .black.opacity(0.5)]
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(content)
            )
    }
}

extension View {
    func applyBookGradientMask() -> some View {
        self.modifier(BookGradientMask())
    }
}


struct BookDetailsGradientMask: ViewModifier {
    var colors: [Color] = [
        UIKitAssets.setColor(for: .background).opacity(1.0),
        UIKitAssets.setColor(for: .background).opacity(0.0),
    ]
    
    var startPoint: UnitPoint = .bottom
    var endPoint: UnitPoint = .center
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
                .mask(content)
            )
    }
}

extension View {
    func applyBookDetailsGradientMask() -> some View {
        self.modifier(BookDetailsGradientMask())
    }
}
