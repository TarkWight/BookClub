//
//  NoveltyCarouselView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct NoveltyCarouselView: View {
    private let books: [NoveltyBook] = [
        NoveltyBook(imageName: "Cover13", title: "Рассвет Жатвы", description: "Долгожданное продолжение «Голодных игр»"),
        NoveltyBook(imageName: "Cover2i", title: "Портрет в тени", description: "Захватывающая история о тайнах прошлого"),
        NoveltyBook(imageName: "Cover0i", title: "Красная Шапочка", description: "Тёмное переосмысление классической сказки"),
        ]

    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedKey.noveltyCarouselLabel)
                .applyFontH2AccentDarkStyle()
                .padding(.horizontal, 16)
                .frame(height: 24)

            GeometryReader { geometry in
                let spacing: CGFloat = 8
                let sideCardWidth: CGFloat = 54
                let centerCardWidth: CGFloat = 242
                let totalWidth = sideCardWidth * 2 + centerCardWidth + spacing * 2

                HStack(spacing: spacing) {
                    NoveltyBookView(book: books[getIndex(-1)], width: sideCardWidth, alignment: .leading)
                    NoveltyBookView(book: books[getIndex(0)], width: centerCardWidth, alignment: .center, showText: true)
                    NoveltyBookView(book: books[getIndex(1)], width: sideCardWidth, alignment: .trailing)
                }
                .frame(width: totalWidth)
                .padding(.horizontal, (geometry.size.width - totalWidth) / 2)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let threshold: CGFloat = 50
                            withAnimation(.easeOut) {
                                if value.translation.width > threshold {
                                    currentIndex = (currentIndex - 1 + books.count) % books.count
                                } else if value.translation.width < -threshold {
                                    currentIndex = (currentIndex + 1) % books.count
                                }
                            }
                        }
                )
            }
            .frame(height: 256)
        }
    }

    private func getIndex(_ offset: Int) -> Int {
        return (currentIndex + offset + books.count) % books.count
    }
}

struct NoveltyBookView: View {
    let book: NoveltyBook
    let width: CGFloat
    let alignment: Alignment
    var showText: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                let width = geo.size.width
                Image(book.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: geo.size.height)
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
            .frame(width: width)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if showText {
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
        .padding(4)
    }
}

struct NoveltyBook: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

#Preview {
    NoveltyCarouselView()
}
