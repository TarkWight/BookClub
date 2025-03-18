//
//  Text+ViewLabelModifier.swift
//  BookClub
//
//  Created by Tark Wight on 18.03.2025.
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
