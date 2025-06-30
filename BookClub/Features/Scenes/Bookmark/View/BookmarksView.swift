//
//  BookmarksView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookmarksView: View {
    @ObservedObject var store: Store<BookmarksState, BookmarksAction>

    var body: some View {
        ZStack {
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Заголовок
                    Text(LocalizedKey.bookmarksLabel)
                        .applyFontH1SecondaryStyle()
                        .padding(.top, 26)
                        .padding(.horizontal, 16)

                    // Секции
                    readingNowSection
                    favoritesSection
                    quotesSection

                    Spacer(minLength: 32)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
        .onDisappear { store.send(.onDisappear) }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: — Секция «Читаю сейчас»
    private var readingNowSection: some View {
        if case .loaded(let dict) = store.state.readingProgress,
            let docId = store.state.currentReadingDocumentId,
            let prog = dict[docId],
            prog > 0 {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedKey.readingNowLabel)
                        .applyFontH2AccentDarkStyle()
                        .padding(.horizontal, 16)
                    ProgressBarView(progress: prog)
                        .padding(.horizontal, 16)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    // MARK: — Секция «Избранное»
    private var favoritesSection: some View {
        if case .loaded(let favs) = store.state.favorites,
            !favs.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedKey.favoritesLabel)
                        .applyFontH2AccentDarkStyle()
                        .padding(.horizontal, 16)
                    ForEach(Array(favs), id: \.self) { bookId in
                        if let book = store.state.booksById[bookId] {
                            BookItemView(book: book)
                                .onTapGesture {
                                    store.send(
                                        .quoteTapped(
                                            documentId: book.documentId
                                        )
                                    )
                                }
                        }
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    // MARK: — Секция «Цитаты»
    private var quotesSection: some View {
        if case .loaded(let items) = store.state.quotes {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizedKey.quotesLabel)
                        .applyFontH2AccentDarkStyle()
                        .padding(.horizontal, 16)

                    ForEach(items, id: \.id) { item in
                         let quoteModel: Quote = {
                            if let book = store.state.booksByDocumentId[
                                item.documentId
                            ] {
                                return Quote(
                                    id: Int(item.id),
                                    text: item.text,
                                    book: book.title,
                                    author: book.authorName ?? "—"
                                )
                            } else {
                                return Quote(
                                    id: Int(item.id),
                                    text: item.text,
                                    book: "—",
                                    author: "—"
                                )
                            }
                        }()

                        QuoteItemView(quote: quoteModel)
                            .onTapGesture {
                                store.send(
                                    .quoteTapped(documentId: item.documentId)
                                )
                            }
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}
