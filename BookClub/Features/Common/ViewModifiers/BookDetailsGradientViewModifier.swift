//
//  BookDetailsGradientViewModifier.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct BookDetailsGradientViewModifier: ViewModifier {
    var colors: [Color] = [
        AppColors.background.opacity(1.0),
        AppColors.background.opacity(0.0),
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
        self.modifier(BookDetailsGradientViewModifier())
    }
}
