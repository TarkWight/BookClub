//
//  BookItemView.swift
//  BookClub
//
//  Created by Tark Wight on 19.03.2025.
//

import SwiftUI

struct BookItemView: View {
    let book: Book

    var body: some View {
        HStack {
            Image(book.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 126)
                .cornerRadius(4)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .applyFontH2AccentDarkStyle()

                Text(book.author)
                    .applyFontBodySmallAccentDarkStyle()
            }
            Spacer()
        }
        .frame(height: 126)
        .padding(.horizontal, 16)
    }
}

