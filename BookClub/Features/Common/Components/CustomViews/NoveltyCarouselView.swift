//
//  NoveltyCarouselView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct NoveltyCarouselView: View {
    let items: [BookDetailsItem]
    let onTap: (BookDetailsItem) -> Void

    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedKey.noveltyCarouselLabel)
                .applyFontH2AccentDarkStyle()
                .frame(height: 24)

            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let spacing = Constants.spacing
                let sideCardWidth = Constants.sideCardWidth
                let centerCardWidth = totalWidth - 2 * (sideCardWidth + spacing)
                let height = centerCardWidth / Constants.cardAspectRatio

                HStack(spacing: spacing) {
                    // previous
                    BookCoverView(
                        book: items[getIndex(-1)],
                        width: sideCardWidth,
                        height: height
                    )

                    // center
                    Button {
                        onTap(items[getIndex(0)])
                    } label: {
                        BookCoverView(
                            book: items[getIndex(0)],
                            width: centerCardWidth,
                            height: height,
                            showTitle: true
                        )
                    }
                    .buttonStyle(.plain)

                    // next
                    BookCoverView(
                        book: items[getIndex(1)],
                        width: sideCardWidth,
                        height: height
                    )
                }
                .frame(width: totalWidth, height: height)
                .gesture(
                    DragGesture().onEnded { value in
                        withAnimation(.easeOut) {
                            if value.translation.width > Constants.threshold {
                                currentIndex =
                                    (currentIndex - 1 + items.count)
                                    % items.count
                            } else if value.translation.width < -Constants
                                .threshold
                            {
                                currentIndex = (currentIndex + 1) % items.count
                            }
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func getIndex(_ offset: Int) -> Int {
        (currentIndex + offset + items.count) % items.count  // Thread 1: Fatal error: Division by zero in remainder operation
    }
}

private struct BookCoverView: View {
    let book: BookDetailsItem
    let width: CGFloat
    let height: CGFloat
    var showTitle: Bool = false

    var body: some View {
        VStack {
            AsyncImage(url: book.coverURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(8)

            if showTitle {
                Text(book.title)
                    .applyFontH3AccentDarkStyle()
                    .lineLimit(2)
                    .frame(maxWidth: width, alignment: .leading)
            }
        }
    }
}

extension NoveltyCarouselView {
    fileprivate enum Constants {
        static let spacing: CGFloat = 8
        static let sideCardWidth: CGFloat = 56
        static let cardAspectRatio: CGFloat = 242 / 256
        static let threshold: CGFloat = 50
        static let cornerRadius: CGFloat = 8
    }
}

#Preview {
    NoveltyCarouselView(
        items: BookDetailsItem.placeholderArray(count: 5),
        onTap: { _ in }
    )
}
