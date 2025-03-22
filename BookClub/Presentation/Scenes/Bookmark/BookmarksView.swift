//
//  BookmarksView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookmarksView: View {
    @ObservedObject var router: Router
    
    let currentReadingBook = Book(imageName: "Cover1", title: "Код Да Винчи", author: "Дэн Браун")
    let currentChapter = "Глава 5"
    let readingProgress: Double = 0.6
    
    let favoriteBooks = BookMock.getBooks(for: .three)
    let quotes: [Quote] = [
        Quote(text: "Иногда, чтобы увидеть свет, нужно пережить темноту.", book: "Код Да Винчи", author: "Дэн Браун"),
        Quote(text: "Мы в ответе за тех, кого приручили.", book: "Маленький принц", author: "Антуан де Сент-Экзюпери")
    ]
    
    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: .background))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(LocalizedKey.bookmarksLabel)
                        .applyFontH1SecondaryStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 26)
                        .padding(.horizontal, 16)
                    
                    readingNowSection
                    favoritesSection
                    quotesSection
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Subviews
private extension BookmarksView {
    
    var readingNowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedKey.readingNowLabel)
                .applyFontH2AccentDarkStyle()
                .padding(.horizontal, 16)
            
            HStack(spacing: 16) {
                Image(currentReadingBook.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 126)
                    .cornerRadius(4)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentReadingBook.title)
                        .applyFontH2AccentDarkStyle()
                    
                    Text(currentChapter)
                        .applyFontBodySmallAccentDarkStyle()
                    
                    ProgressBarView(progress: readingProgress)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 126)
        }
    }
    
    var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedKey.favoritesLabel)
                .applyFontH2AccentDarkStyle()
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                ForEach(favoriteBooks) { book in
                    BookItemView(book: book)
                }
            }
        }
    }
    
    var quotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedKey.quotesLabel)
                .applyFontH2AccentDarkStyle()
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                ForEach(quotes) { quote in
                    quoteItem(quote)
                }
            }
        }
    }
      
    func quoteItem(_ quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“\(quote.text)”")
                .applyFontQuoteAccentDarkStyle()
            
            Text("\(quote.book) • \(quote.author)")
                .applyFontTextAccentDarkStyle()
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UIKitAssets.setColor(for: .accentLight))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

// MARK: - Models
struct Quote: Identifiable {
    let id = UUID()
    let text: String
    let book: String
    let author: String
}

#Preview {
    BookmarksView(router: Router())
}
