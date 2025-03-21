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
    let genres = SearchMock.genres
    let authors = SearchMock.authors
    
    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
                    searchField
                    recentSearchesSection
                    genresSection
                    authorsSection
                }
            }
        }
    }
}

// MARK: - UI Elements
private extension SearchView {
    
    var searchField: some View {
        HStack {
            UIKitAssets.setImage(for: UIKitAssets.imageSearch)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentMedium))
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .padding(.leading, Constants.sidePadding)
            
            TextField(LocalizedKey.seatchFieldPlaceholder, text: $searchText)
                .padding(.leading, Constants.textFieldPadding)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    UIKitAssets.setImage(for: UIKitAssets.imageClose)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                        .frame(width: Constants.iconSize, height: Constants.iconSize)
                        .padding(.trailing, Constants.sidePadding)
                }
            }
        }
        .frame(height: Constants.searchFieldHeight)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark), lineWidth: Constants.borderWidth)
        )
        .padding(.horizontal, Constants.sidePadding)
    }
    
    var recentSearchesSection: some View {
        Group {
            if !recentQueries.isEmpty {
                Text(LocalizedKey.recentRequestsLabel)
                    .applySubtitleLabelStyle()
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
                .applySubtitleLabelStyle()
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
                .applySubtitleLabelStyle()
                .padding(.horizontal, Constants.sidePadding)
            
            ForEach(authors, id: \.name) { author in
                authorItem(author)
            }
        }
    }
}

// MARK: - UI Items
private extension SearchView {
    
    func recentQueryItem(_ query: String) -> some View {
        HStack {
            UIKitAssets.setImage(for: UIKitAssets.imageHistory)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .padding(.leading, Constants.sidePadding)
            
            Text(query)
                .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
            
            Spacer()
            
            Button(action: {
                recentQueries.removeAll { $0 == query }
            }) {
                UIKitAssets.setImage(for: UIKitAssets.imageClose)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .padding(.trailing, Constants.sidePadding)
            }
        }
        .frame(height: Constants.recentQueryHeight)
        .background(UIKitAssets.setColor(for: UIKitAssets.colorAccentLight))
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal, Constants.sidePadding)
        .onTapGesture {
            print("Недавний запрос выбран: \(query)")
        }
    }
    
    func genreItem(_ genre: String) -> some View {
        Text(genre)
            .applySmallBodyLabelStyle()
            .frame(width: Constants.genreWidth, height: Constants.genreHeight)
            .background(UIKitAssets.setColor(for: UIKitAssets.colorAccentLight))
            .cornerRadius(Constants.cornerRadius)
            .onTapGesture {
                print("Жанр выбран: \(genre)")
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
                .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                .padding(.leading, Constants.textFieldPadding)
            
            Spacer()
        }
        .frame(height: Constants.authorRowHeight)
        .background(UIKitAssets.setColor(for: UIKitAssets.colorAccentLight))
        .cornerRadius(Constants.cornerRadius)
        .padding(.horizontal, Constants.sidePadding)
        .onTapGesture {
            print("Автор выбран: \(author.name)")
        }
    }
}

// MARK: - Constants
private extension SearchView {
    enum Constants {
        static let sectionSpacing: CGFloat = 16
        static let sidePadding: CGFloat = 16
        static let textFieldPadding: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let gridSpacing: CGFloat = 8
        
        static let searchFieldHeight: CGFloat = 44
        static let recentQueryHeight: CGFloat = 56
        
        static let genreHeight: CGFloat = 48
        @MainActor
        static var genreWidth: CGFloat {
            (UIScreen.main.bounds.width - (2 * sidePadding) - (gridSpacing * 1)) / 2
        }
        
        static let authorRowHeight: CGFloat = 72
        static let authorImageSize: CGFloat = 48
        static let iconSize: CGFloat = 20
    }
}

#Preview {
    SearchView(router: Router())
}
