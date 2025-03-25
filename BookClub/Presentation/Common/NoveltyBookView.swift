//
//  NoveltyBookView.swift
//  BookClub
//
//  Created by Tark Wight on 25.03.2025.
//

import SwiftUI

struct NoveltyBookView: View {
    let book: NoveltyBook
    let width: CGFloat
    let fullHeight: CGFloat
    let alignment: Alignment
    var showText: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            bookImage
            if showText {
                bookText
            }
        }
        .frame(width: width, height: fullHeight)
        .padding(4)
    }
}

// MARK: - UI Components

private extension NoveltyBookView {
    var bookImage: some View {
        Image(book.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: fullHeight)
            .applyBookGradientMask()
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .alignmentGuide(.leading) { _ in
                alignment == .leading ? -width / 2 : 0
            }
            .alignmentGuide(.trailing) { _ in
                alignment == .trailing ? width / 2 : 0
            }
    }

    var bookText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.description)
                .font(.footnote)
                .foregroundColor(AppColors.white)
                .lineLimit(2)

            Text(book.title)
                .font(.headline)
                .bold()
                .foregroundColor(AppColors.white)
        }
        .padding()
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
}
