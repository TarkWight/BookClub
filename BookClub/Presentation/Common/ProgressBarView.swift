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
                .fill(AppColors.accentMedium)
                .frame(height: 8)

            RoundedRectangle(cornerRadius: 4)
                .fill(AppColors.accentDark)
                .frame(width: CGFloat(progress) * UIScreen.main.bounds.width, height: 8)
        }
    }
}
