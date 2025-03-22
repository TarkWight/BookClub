//
//  ProgressBarView.swift
//  BookClub
//
//  Created by Tark Wight on 19.03.2025.
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(UIKitAssets.setColor(for: .accentMedium))
                .frame(height: 8)

            RoundedRectangle(cornerRadius: 4)
                .fill(UIKitAssets.setColor(for: .accentDark))
                .frame(width: CGFloat(progress) * UIScreen.main.bounds.width, height: 8)
        }
    }
}
