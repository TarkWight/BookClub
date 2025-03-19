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



