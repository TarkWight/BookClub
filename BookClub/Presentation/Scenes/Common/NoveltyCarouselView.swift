//
//  NoveltyCarouselView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct NoveltyCarouselView: View {
    @ObservedObject var router: Router

    private let books: [NoveltyBook] = [
        NoveltyBook(imageName: "Cover13", title: "Рассвет Жатвы", description: "Долгожданное продолжение «Голодных игр»"),
        NoveltyBook(imageName: "Cover2i", title: "Портрет в тени", description: "Захватывающая история о тайнах прошлого"),
        NoveltyBook(imageName: "Cover0i", title: "Красная Шапочка", description: "Тёмное переосмысление классической сказки"),
    ]

    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            title
            carousel
        }
    }
}

// MARK: - UI Components

private extension NoveltyCarouselView {
    var title: some View {
        Text(LocalizedKey.noveltyCarouselLabel)
            .applyFontH2AccentDarkStyle()
            .frame(height: 24)
    }

    var carousel: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let spacing = Constants.spacing
            let sideCardWidth = Constants.sideCardWidth
            let centerCardWidth = totalWidth - 2 * (sideCardWidth + spacing)

            let height = centerCardWidth / Constants.cardAspectRatio

            HStack(spacing: spacing) {
                NoveltyBookView(
                    book: books[getIndex(-1)],
                    width: sideCardWidth,
                    fullHeight: Constants.cardHeight,
                    alignment: .leading
                )

                Button {
                    router.navigateTo(.bookDetails)
                } label: {
                    NoveltyBookView(
                        book: books[getIndex(0)],
                        width: centerCardWidth,
                        fullHeight: Constants.cardHeight,
                        alignment: .center,
                        showText: true
                    )
                }
                .buttonStyle(.plain)

                NoveltyBookView(
                    book: books[getIndex(1)],
                    width: sideCardWidth,
                    fullHeight: Constants.cardHeight,
                    alignment: .trailing
                )
            }
            .frame(width: totalWidth, height: height)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        withAnimation(.easeOut) {
                            if value.translation.width > Constants.threshold {
                                currentIndex = (currentIndex - 1 + books.count) % books.count
                            } else if value.translation.width < -Constants.threshold {
                                currentIndex = (currentIndex + 1) % books.count
                            }
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity)
    }

    func getIndex(_ offset: Int) -> Int {
        (currentIndex + offset + books.count) % books.count
    }
}

// MARK: - Constants

private extension NoveltyCarouselView {
    enum Constants {
        static let sidePadding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let sideCardWidth: CGFloat = 56
        static let cardAspectRatio: CGFloat = 242 / 256
        static let threshold: CGFloat = 50
        static let centerCardWidth: CGFloat = 242
        static let cardHeight = centerCardWidth / cardAspectRatio
    }
}

#Preview {
    NoveltyCarouselView(router: Router())
}
