//
//  BookItemView.swift
//  BookClub
//
//  Created by Tark Wight on 19.03.2025.
//

import SwiftUI

struct BookItemView: View {
    let book: BookDetailsItem

    var body: some View {
        HStack {
            if let url = book.coverURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.2)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.red.opacity(0.1)
                    @unknown default:
                        Color.gray
                    }
                }
                .frame(width: 80, height: 126)
                .clipped()
                .cornerRadius(4)
            } else {
                Image("Cover1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 126)
                    .clipped()
                    .cornerRadius(4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .applyFontH2AccentDarkStyle()

                Text(book.authorName ?? LocalizedKey.authorPlaceholder)
                    .applyFontBodySmallAccentDarkStyle()
            }

            Spacer()
        }
        .frame(height: 126)
        .padding(.horizontal, 16)
    }
}
