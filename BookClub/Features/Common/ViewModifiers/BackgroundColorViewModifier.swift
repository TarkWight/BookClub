//
//  BackgroundColorViewModifier.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import SwiftUI

struct BackgroundColorViewModifier: ViewModifier {

    let color: Color

    func body(content: Content) -> some View {
        ZStack {
            color
                .ignoresSafeArea()

            content
        }
    }
}

extension View {
    func backgroundColor(_ color: Color = .appBackground) -> some View {
        modifier(BackgroundColorViewModifier(color: color))
    }
}
