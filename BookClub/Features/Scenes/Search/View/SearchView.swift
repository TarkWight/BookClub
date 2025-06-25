//
//  SearchView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var store: Store<SearchState, SearchAction>

    var body: some View {
        ZStack {
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: SearchViewConstants.sectionSpacing
                ) {

                    searchField
                        .padding(.horizontal, SearchViewConstants.sidePadding)

                    if store.state.isSearching {
                        searchResultsSection
                            .padding(
                                .horizontal,
                                SearchViewConstants.sidePadding
                            )
                    } else {
                        recentSearchesSection
                            .padding(
                                .horizontal,
                                SearchViewConstants.sidePadding
                            )
                        genresSection
                            .padding(
                                .horizontal,
                                SearchViewConstants.sidePadding
                            )
                        authorsSection
                            .padding(
                                .horizontal,
                                SearchViewConstants.sidePadding
                            )
                    }
                }
            }
        }
        .onAppear { store.send(.onAppear) }
        .refreshable {
            store.send(.fetchRemoteAuthors)
            store.send(.fetchRemoteGenres)
        }
        .sheet(
            isPresented: Binding(
                get: { store.state.lastErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.dismissError)
                    }
                }
            )
        ) {
            if let msg = store.state.lastErrorMessage {
                ErrorView(message: msg)
            }
        }
    }
}

// MARK: — UI Elements
extension SearchView {
    var currentQueryText: String {
        switch store.state.filter {
        case .text(let tag): return tag
        case .genre(let genre): return genre.name
        case .author(let author): return author.name
        default: return ""
        }
    }

    fileprivate var searchText: Binding<String> {
        Binding(
            get: {
                switch store.state.filter {
                case .text(let value):
                    return value
                case .genre(let genre):
                    return genre.name
                case .author(let author):
                    return author.name
                case .empty:
                    return ""
                case .none:
                    return ""
                }
            },
            set: { newValue in
                store.send(.didChangeSearchText(newValue))
            }
        )
    }

    fileprivate var searchField: some View {
        HStack {
            AppImages.search
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppColors.accentMedium)
                .frame(
                    width: SearchViewConstants.iconSize,
                    height: SearchViewConstants.iconSize
                )

            TextField(
                LocalizedKey.searchFieldPlaceholder,
                text: searchText,
                onCommit: { store.send(.didTapSearch) }
            )
            .font(AppFonts.body)
            .foregroundColor(AppColors.accentDark)
            .padding(.leading, SearchViewConstants.textFieldPadding)

            if !searchText.wrappedValue.isEmpty {
                Button {
                    store.send(.didClearSearch)
                } label: {
                    AppImages.close
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppColors.accentDark)
                        .frame(
                            width: SearchViewConstants.iconSize,
                            height: SearchViewConstants.iconSize
                        )
                }
            }
        }
        .frame(height: SearchViewConstants.searchFieldHeight)
        .background(AppColors.white)
        .overlay(
            RoundedRectangle(cornerRadius: SearchViewConstants.cornerRadiusBig)
                .stroke(
                    AppColors.accentMedium,
                    lineWidth: SearchViewConstants.borderWidth
                )
        )
    }

    fileprivate var recentSearchesSection: some View {
        VStack(
            alignment: .leading,
            spacing: SearchViewConstants.sectionSpacing
        ) {
            if !store.state.recentSearches.isEmpty {
                Text(LocalizedKey.recentRequestsLabel)
                    .applyFontH2AccentDarkStyle()

                ForEach(store.state.recentSearches, id: \.self) { query in
                    HStack {
                        AppImages.history
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(AppColors.accentDark)
                            .frame(
                                width: SearchViewConstants.iconSize,
                                height: SearchViewConstants.iconSize
                            )

                        Text(query)
                            .foregroundColor(AppColors.accentDark)

                        Spacer()

                        Button {
                            store.send(.didClearSearch)
                        } label: {
                            AppImages.close
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(AppColors.accentDark)
                                .frame(
                                    width: SearchViewConstants.iconSize,
                                    height: SearchViewConstants.iconSize
                                )
                        }
                    }
                    .frame(height: SearchViewConstants.recentQueryHeight)
                    .background(AppColors.accentLight)
                    .cornerRadius(SearchViewConstants.cornerRadius)
                    .onTapGesture {
                        store.send(.didSelectRecentSearch(query))
                    }
                }
            }
        }
    }

    fileprivate var genresSection: some View {
        VStack(
            alignment: .leading,
            spacing: SearchViewConstants.sectionSpacing
        ) {
            Text(LocalizedKey.genresLabel)
                .applyFontH2AccentDarkStyle()

            switch store.state.genres {
            case .idle, .loading:
                ProgressView()
            case .loaded(let items):
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ],
                    spacing: SearchViewConstants.itemSpacing
                ) {
                    ForEach(items) { genre in
                        Text(genre.name)
                            .applyFontBodySmallAccentDarkStyle()
                            .frame(
                                maxWidth: .infinity,
                                minHeight: SearchViewConstants.genreHeight
                            )
                            .background(AppColors.accentLight)
                            .cornerRadius(SearchViewConstants.cornerRadius)
                            .onTapGesture {
                                store.send(.didSelectGenre(genre))
                            }
                    }
                }
            case .failure(let message):
                ErrorView(message: message)
            }
        }
    }

    fileprivate var authorsSection: some View {
        VStack(
            alignment: .leading,
            spacing: SearchViewConstants.sectionSpacing
        ) {
            Text(LocalizedKey.authorsLabel)
                .applyFontH2AccentDarkStyle()

            switch store.state.authors {
            case .idle, .loading:
                ProgressView()
            case .loaded(let items):
                ForEach(items) { author in
                    HStack {
                        if let url = author.imageUrl.flatMap(URL.init(string:))
                        {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(
                                width: SearchViewConstants.authorImageSize,
                                height: SearchViewConstants.authorImageSize
                            )
                            .clipShape(Circle())
                        }
                        Text(author.name)
                            .foregroundColor(AppColors.accentDark)
                        Spacer()
                    }
                    .frame(height: SearchViewConstants.authorRowHeight)
                    .background(AppColors.accentLight)
                    .cornerRadius(SearchViewConstants.cornerRadius)
                    .onTapGesture {
                        store.send(.didSelectAuthor(author))
                    }
                }
            case .failure(let message):
                ErrorView(message: message)
            }
        }
    }

    fileprivate var searchResultsSection: some View {
        VStack(
            alignment: .leading,
            spacing: SearchViewConstants.sectionSpacing
        ) {
            switch store.state.searchResults {
            case .idle:
                EmptyView()

            case .loading:
                ProgressView()

            case .loaded(let items):
                if items.isEmpty {
                    Text("По запросу «\(currentQueryText)» ничего не найдено")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(items) { book in
                        BookCell(book: book) {
                            store.send(
                                .didSelectBook(documentId: book.documentId)
                            )
                        }
                    }
                }

            case .failure:
                EmptyView()
            }
        }
    }
}

// MARK: — BookCell
private struct BookCell: View {
    let book: BookDetailsItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(
                alignment: .top,
                spacing: BookCellConstants.itemSpacing
            ) {
                AsyncImage(url: book.coverURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(
                    width: BookCellConstants.bookImageWidth,
                    height: BookCellConstants.bookImageHeight
                )
                .cornerRadius(BookCellConstants.cornerRadius)

                VStack(
                    alignment: .leading,
                    spacing: BookCellConstants.itemSpacing
                ) {
                    Text(book.title)
                        .applyFontH3AccentDarkStyle()
                        .lineLimit(2)
                    Text(book.documentId)
                        .applyFontFootNoteStyle()
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, BookCellConstants.verticalPadding)
        }
        .buttonStyle(.plain)
    }
}

// MARK: — SearchView Constants
private enum SearchViewConstants {
    static let sectionSpacing: CGFloat = 16
    static let sidePadding: CGFloat = 16
    static let textFieldPadding: CGFloat = 8
    static let borderWidth: CGFloat = 1
    static let cornerRadiusBig: CGFloat = 10
    static let cornerRadius: CGFloat = 8
    static let recentQueryHeight: CGFloat = 56
    static let genreHeight: CGFloat = 48
    static let authorRowHeight: CGFloat = 56
    static let authorImageSize: CGFloat = 40
    static let iconSize: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let searchFieldHeight: CGFloat = 44
}

// MARK: — BookCell Constants
private enum BookCellConstants {
    static let bookImageWidth: CGFloat = 60
    static let bookImageHeight: CGFloat = 90
    static let cornerRadius: CGFloat = 8
    static let itemSpacing: CGFloat = 12
    static let verticalPadding: CGFloat = 8
}

#Preview {
    SearchView(
        store: Store<SearchState, SearchAction>(
            initialState: .init(),
            reducer: { _, _ in .none }
        )
    )
}
