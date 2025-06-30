//
//  LibraryView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var store: Store<LibraryState, LibraryAction>

    private let columns: [GridItem] =
        Array(
            repeating: .init(.flexible(), spacing: Constants.itemSpacing),
            count: 3
        )

    var body: some View {
        ZStack {
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                Text(LocalizedKey.libraryLabel)
                    .applyFontH1SecondaryStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Constants.topPadding)
                    .padding(.horizontal, Constants.sidePadding)

                // MARK: — Новые книги
                switch store.state.newBooks {
                case .idle, .loading:
                    ProgressView()
                        .frame(height: Constants.carouselHeight)

                case .loaded(let items):
                    NoveltyCarouselView(items: items) { book in
                        store.send(.didSelectBook(documentId: book.documentId))
                    }
                    .frame(height: Constants.carouselHeight)
                    .padding(.horizontal, Constants.sidePadding)

                case let .failure(message):
                    ErrorView(message: message)
                        .frame(height: Constants.carouselHeight)
                }

                // MARK: — Популярные книги
                Text(LocalizedKey.popularGridLabel)
                    .applyFontH2AccentDarkStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.sidePadding)

                switch store.state.popularBooks {
                case .idle, .loading:
                    ProgressView()
                        .frame(height: Constants.bookCoverHeight + 50)

                case .loaded(let books):
                    LazyVGrid(columns: columns, spacing: Constants.itemSpacing) {
                        ForEach(books) { book in
                            BookCell(book: book) {
                                store.send(
                                    .didSelectBook(documentId: book.documentId)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, Constants.sidePadding)

                case let .failure(message):
                    ErrorView(message: message)
                        .padding(.horizontal, Constants.sidePadding)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
        //        .onAppear {
        //            store.send(.fetchLocalNewBooks)
        //            store.send(.fetchLocalPopularBooks)
        //        }
        .refreshable {
            store.send(.requestNewBooks)
            store.send(.requestPopularBooks(page: 1))
        }
    }
}

// MARK: — BookCell для отображения одной книги

extension LibraryView {
    fileprivate struct BookCell: View {
        let book: BookDetailsItem
        let onTap: () -> Void

        var body: some View {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: Constants.textSpacing) {
                    AsyncImage(url: book.coverURL) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(
                        width: Constants.bookWidth,
                        height: Constants.bookCoverHeight
                    )
                    .clipped()
                    .cornerRadius(Constants.cornerRadius)

                    Text(book.title)
                        .applyFontH3AccentDarkStyle()
                        .lineLimit(2)
                    Text(book.documentId)
                        .applyFontFootNoteStyle()
                        .foregroundColor(.secondary)
                }
                .frame(width: Constants.bookWidth)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: — Константы

extension LibraryView {
    fileprivate enum Constants {
        static let topPadding: CGFloat = 26
        static let sidePadding: CGFloat = 16
        static let bottomPadding: CGFloat = 16
        static let itemSpacing: CGFloat = 16

        static let bookWidth: CGFloat = 112
        static let bookCoverHeight: CGFloat = 175
        static let textSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 8

        static let carouselHeight: CGFloat = 200
    }
}

// MARK: — Превью

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(
            store: Store(
                initialState: .init(),
                reducer: { _, _ in .none }
            )
        )
    }
}

#Preview {
    LibraryView(
        store: Store<LibraryState, LibraryAction>(
            initialState: .init(),
            reducer: { _, _ in
                return .none
            }
        )
    )
}
