//
//  BookItemView.swift
//  BookClub
//
//  Created by Tark Wight on 19.03.2025.
//

import SwiftUI

struct BookItemView: View {
    var body: some View {
        HStack {
            Image("Cover1")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 126)
                .cornerRadius(4)

            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedKey.bookTitlePlaceholder)
                    .applyFontH2AccentDarkStyle()

                Text(LocalizedKey.authorPlaceholder)
                    .applyFontBodySmallAccentDarkStyle()
            }
            Spacer()
        }
        .frame(height: 126)
        .padding(.horizontal, 16)
    }
}
