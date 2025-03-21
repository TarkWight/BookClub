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
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            
            ScrollView {
                Text(LocalizedKey.libraryLabel)
                    .applyFontH1SecondaryStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, Constants.topPadding)
                    .padding(.horizontal, Constants.sidePadding)
                
                
                NoveltyCarouselView()
                
                Text(LocalizedKey.popularGridLabel)
                    .applyFontH2AccentDarkStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Constants.sidePadding)
                
                
                LazyVGrid(columns: columns, alignment: .leading, spacing: Constants.itemSpacing) {
                    ForEach(BookMock.getBooks()) { book in
                        BookCell(book: book)
                            .frame(maxHeight: .infinity, alignment: .top)
                    }
                }
                .padding(.horizontal, Constants.sidePadding)
                .padding(.bottom, Constants.bottomPadding)
            }
        }
    }
    
    struct BookCell: View {
        let book: Book
        
        var body: some View {
            VStack(alignment: .leading, spacing: Constants.textSpacing) {
                Image(book.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Constants.bookWidth, height: Constants.bookCoverHeight)
                    .cornerRadius(Constants.cornerRadius)
                
                Text(book.title)
                    .applyFontH3AccentDarkStyle()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: Constants.bookWidth, alignment: .leading)
                
                Text(book.author)
                    .applyFontFootNoteStyle()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: Constants.bookWidth, alignment: .leading)
            }
            .frame(width: Constants.bookWidth)
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
    }
}

#Preview {
    LibraryView(router: Router())
}
