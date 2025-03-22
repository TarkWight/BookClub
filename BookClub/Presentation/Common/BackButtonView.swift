//
//  BackButtonView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//


import SwiftUI

enum BackButtonColor {
    case dark
    case light
}

struct BackButtonView: View {
    let action: () -> Void
    let title: String
    let color: BackButtonColor
    let darkColor: Color = UIKitAssets.setColor(for: .accentDark)
    let lightColor: Color = UIKitAssets.setColor(for: .white)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                UIKitAssets.setImage(for: .arrowLeft)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(color == .dark ?  darkColor : lightColor)
                    
                    
                    
                Text(title)
                    .font(UIKitAssets.setFont(for: .body).font)
                    .foregroundColor(color == .dark ?  darkColor : lightColor)
                    .frame(width: 50, alignment: .leading)
            }
        }
        .frame(width: 80, height: 24)
    }
}

#Preview {
    BackButtonView(action: {}, title: LocalizedKey.backButtonTitle, color: .light)
}
