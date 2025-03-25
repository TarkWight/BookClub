//
//  SearchView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var router: Router
    @State private var searchText: String = ""
    @State private var recentQueries: [String] = SearchMock.recentSearches
    let genres: [String] = SearchMock.genres
    let authors: [SearchMock.Author] = SearchMock.authors
    let books: [Book] = BookMock.getBooks(for: .all)

    @State private var isSearching: Bool = false

    var body: some View {
        ZStack {
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
                    searchField

                    if isSearching {
                        searchResultsSection
                    } else {
                        recentSearchesSection
                        genresSection
                        authorsSection
                    }
                }
            }
        }
    }
}

// MARK: - UI Elements
private extension SearchView {

    var searchField: some View {
        HStack {
            AppImages.search
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppColors.accentMedium)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .padding(.leading, Constants.sidePadding)

            TextField(LocalizedKey.searchFieldPlaceholder, text: $searchText, onEditingChanged: { _ in
                withAnimation {
                    isSearching = !searchText.isEmpty
                }
            })
            .font(AppFonts.body)
            .foregroundColor(AppColors.accentDark)
            .padding(.leading, Constants.textFieldPadding)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    withAnimation {
                        isSearching = false
                    }
                }, label: {
                    AppImages.close
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(AppColors.accentDark)
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                        .padding(.trailing, Constants.sidePadding)
                })
            }
        }
        .frame(height: Constants.searchFieldHeight)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadiusBig)
                .stroke(AppColors.accentMedium, lineWidth: Constants.borderWidth)
        )
        .background(AppColors.white)
        .padding(.horizontal, Constants.sidePadding)
    }

    var recentSearchesSection: some View {
        Group {
            if !recentQueries.isEmpty {
                Text(LocalizedKey.recentRequestsLabel)
                    .applyFontH2AccentDarkStyle()
                    .padding(.horizontal, Constants.sidePadding)

                ForEach(recentQueries, id: \.self) { query in
                    recentQueryItem(query)
                }
            }
        }
    }

    var genresSection: some View {
        VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
            Text(LocalizedKey.genresLabel)
                .applyFontH2AccentDarkStyle()
                .padding(.horizontal, Constants.sidePadding)

            LazyVGrid(columns: [
                GridItem(.fixed(Constants.genreWidth)),
                GridItem(.fixed(Constants.genreWidth))
            ]) {
                ForEach(genres, id: \.self) { genre in
                    genreItem(genre)
                }
            }
            .padding(.horizontal, Constants.sidePadding)
        }
    }

    var authorsSection: some View {
        VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
            Text(LocalizedKey.authorsLabel)
                .applyFontH2AccentDarkStyle()
                .padding(.horizontal, Constants.sidePadding)

            ForEach(authors, id: \.name) { author in
                authorItem(author)
            }
        }
    }

    var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: Constants.sectionSpacing) {

            ForEach(books.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.author.localizedCaseInsensitiveContains(searchText) }) { book in
                bookItem(book)
            }
        }
    }
}

// MARK: - UI Items
private extension SearchView {
    func recentQueryItem(_ query: String) -> some View {
        HStack {
            AppImages.history
                .resizable()
                .renderingMode(.template)
                .foregroundColor(AppColors.accentDark)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .padding(.leading, Constants.sidePadding)

            Text(query)
                .foregroundColor(AppColors.accentDark)

            Spacer()

            Button(action: {
                recentQueries.removeAll { $0 == query }
            }, label: {
                AppImages.close
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(AppColors.accentDark)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .padding(.trailing, Constants.sidePadding)
            })
        }
        .frame(height: Constants.recentQueryHeight)
        .background(AppColors.accentLight)
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal, Constants.sidePadding)
        .onTapGesture {
            searchText = query
            isSearching = true
        }
    }

    func genreItem(_ genre: String) -> some View {
        Text(genre)
            .applyFontBodySmallAccentDarkStyle()
            .frame(width: Constants.genreWidth, height: Constants.genreHeight)
            .background(AppColors.accentLight)
            .cornerRadius(Constants.cornerRadius)
            .onTapGesture {
                searchText = genre
                isSearching = true
            }
    }

    func authorItem(_ author: SearchMock.Author) -> some View {
        HStack {
            Image(author.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.authorImageSize, height: Constants.authorImageSize)
                .clipShape(Circle())
                .padding(.leading, Constants.sidePadding)

            Text(author.name)
                .foregroundColor(AppColors.accentDark)
                .padding(.leading, Constants.textFieldPadding)

            Spacer()
        }
        .frame(height: Constants.authorRowHeight)
        .background(AppColors.accentLight)
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal, Constants.sidePadding)
        .onTapGesture {
            searchText = author.name
            isSearching = true
        }
    }

    func bookItem(_ book: Book) -> some View {
        HStack {
            Image(book.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 126)
                .cornerRadius(Constants.cornerRadiusSmall)

            VStack(alignment: .leading) {
                Text(book.title)
                    .applyFontH2AccentDarkStyle()

                Text(book.author)
                    .applyFontBodySmallAccentDarkStyle()
            }

            Spacer()
        }
        .frame(height: Constants.bookRowHeight)
        .padding(.horizontal, Constants.sidePadding)
    }
}

// MARK: - Constants
private extension SearchView {
    enum Constants {
        static let sectionSpacing: CGFloat = 16
        static let sidePadding: CGFloat = 16
        static let textFieldPadding: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let cornerRadiusBig: CGFloat = 10
        static let cornerRadius: CGFloat = 8
        static let cornerRadiusSmall: CGFloat = 4
        static let gridSpacing: CGFloat = 8

        static let searchFieldHeight: CGFloat = 44
        static let recentQueryHeight: CGFloat = 56

        static let genreHeight: CGFloat = 48
        @MainActor
        static var genreWidth: CGFloat {
            (UIScreen.main.bounds.width - (2 * sidePadding) - (gridSpacing * 1)) / 2
        }

        static let bookRowHeight: CGFloat = 126

        static let authorRowHeight: CGFloat = 72
        static let authorImageSize: CGFloat = 48
        static let iconSize: CGFloat = 20
    }
}

#Preview {
    SearchView(router: Router())
}
