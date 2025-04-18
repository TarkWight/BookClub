//
//  LibraryView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var router: Router

    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: Constants.itemSpacing), count: 3)

    var body: some View {
        ZStack {
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                header
                carousel
                Spacer()
                    .frame(width: 10)
                popularSection
            }
        }
    }
}

// MARK: - UI Components

private extension LibraryView {

    var header: some View {
        Text(LocalizedKey.libraryLabel)
            .applyFontH1SecondaryStyle()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Constants.topPadding)
            .padding(.horizontal, Constants.sidePadding)
    }

    var carousel: some View {
        NoveltyCarouselView(router: router)
            .padding(.horizontal, 32)
            .padding(.bottom, 256)
    }

    var popularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedKey.popularGridLabel)
                .applyFontH2AccentDarkStyle()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Constants.sidePadding)

            LazyVGrid(columns: flexibleColumns, spacing: Constants.itemSpacing) {
                ForEach(BookMock.getBooks(for: .all)) { book in
                    BookCell(book: book, router: router)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, Constants.bottomPadding)
    }

    private var flexibleColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: Constants.bookWidth, maximum: Constants.bookWidth), spacing: Constants.itemSpacing),
            count: 3
        )
    }
}

extension LibraryView {
    struct BookCell: View {
        let book: Book
        @ObservedObject var router: Router

        var body: some View {
            Button {
                router.navigateTo(.bookDetails)
            } label: {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = width / Constants.bookAspectRatio

                    VStack(alignment: .leading, spacing: Constants.textSpacing) {
                        Image(book.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .clipped()
                            .cornerRadius(Constants.cornerRadius)

                        Text(book.title)
                            .applyFontH3AccentDarkStyle()
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(book.author)
                            .applyFontFootNoteStyle()
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(width: width)
                }
                .frame(minHeight: Constants.bookCoverHeight + 30)
            }
            .buttonStyle(.plain)
        }
    }
}

private extension LibraryView {
    enum Constants {
        static let topPadding: CGFloat = 26
        static let sidePadding: CGFloat = 16
        static let bottomPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24

        static let itemSpacing: CGFloat = 16
        static let bookWidth: CGFloat = 112
        static let bookCoverHeight: CGFloat = 175
        static let textSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8

        static let bookAspectRatio: CGFloat = 112 / 175
    }
}

#Preview {
    LibraryView(router: Router())
}
