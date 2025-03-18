//
//  BackButtonView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//


import SwiftUI

struct BackButtonView: View {
    let action: () -> Void
    let title: String

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                UIKitAssets.setImage(for: UIKitAssets.imageArrowLeft)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                    
                    
                Text(title)
                    .font(UIKitAssets.setFont(UIKitAssets.fontBody).font)
                    .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                    .frame(width: 50, alignment: .leading)
            }
        }
        .frame(width: 80, height: 24)
    }
}

#Preview {
    BackButtonView(action: {}, title: LocalizedKey.backButtonTitle)
}
