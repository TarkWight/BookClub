//
//  BookDetailsView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookDetailsView: View {
    @ObservedObject var router: Router
    
    private let book = BookDetails(
        imageName: "pl",
        title: "Код Да Винчи",
        author: "Дэн Браун",
        description: """
        Секретный код скрыт в работах Леонардо да Винчи...
        
        Только он поможет найти христианские святыни, дающие немыслимые власть и могущество... 
        
        Ключ к величайшей тайне, над которой человечество билось веками, наконец может быть найден...
        """,
        chapters: [
            Chapter(title: "Факты", status: .read),
            Chapter(title: "Пролог", status: .reading),
            Chapter(title: "Глава 1", status: .unread),
            Chapter(title: "Глава 2", status: .unread),
            Chapter(title: "Глава 3", status: .unread),
            Chapter(title: "Глава 4", status: .unread),
            Chapter(title: "Глава 5", status: .unread),
            Chapter(title: "Глава 6", status: .unread),
            Chapter(title: "Глава 7", status: .unread),
        ]
    )
    
    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
                    
                    BackButtonView(action: { router.navigateTo(.mainTab) }, title: LocalizedKey.backButtonTitle)
                        .padding(.top, Constants.topPadding)
                    
                    Image(book.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: Constants.coverHeight)
                        .applyBookDetailsGradientMask()
                        .clipped()
                    
                    HStack {
                        Button(action: { router.navigateTo(.reader) }) {
                            Text(LocalizedKey.readButtonTitle)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                                .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorWhite))
                                .cornerRadius(Constants.buttonCornerRadius)
                        }
                        
                        Button(action: { print("Книга добавлена в избранное") }) {
                            Text(LocalizedKey.addToBookmarkButtonTitle)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(UIKitAssets.setColor(for: UIKitAssets.colorWhite))
                                .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                                .cornerRadius(Constants.buttonCornerRadius)
                        }
                    }
                    .padding(.horizontal, Constants.sidePadding)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .applyTextLabelStyle()
                            .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                        
                        Text(book.author)
                            .applyBookAuthorStyle()
                    }
                    .padding(.horizontal, Constants.sidePadding)
                    
                    Text(book.description)
                        .font(.body)
                        .padding(.horizontal, Constants.sidePadding)
                    
                    VStack(alignment: .leading) {
                        Text(LocalizedKey.progressBarLabel)
                            .applySubtitleLabelStyle()
                        
                        ProgressView(value: progress(), total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: Constants.progressBarHeight)
                            .background(UIKitAssets.setColor(for: UIKitAssets.colorAccentMedium))
                            .cornerRadius(Constants.progressBarCornerRadius)
                    }
                    .padding(.horizontal, Constants.sidePadding)
                    
                    VStack(alignment: .leading, spacing: Constants.chapterSpacing) {
                        Text(LocalizedKey.listOfContentsLabel)
                            .applySubtitleLabelStyle()
                        
                        ForEach(book.chapters) { chapter in
                            HStack {
                                Text(chapter.title)
                                    .font(.body)
                                    .foregroundColor(UIKitAssets.setColor(for: UIKitAssets.colorAccentDark))
                                
                                Spacer()
                                
                                Image(chapter.status.iconName)
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: Constants.chapterIconSize, height: Constants.chapterIconSize)
                                    .foregroundColor(chapter.status.iconColor)
                            }
                        }
                    }
                    .padding(.horizontal, Constants.sidePadding)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func progress() -> Double {
        let readChapters = book.chapters.filter { $0.status == .read }.count
        return Double(readChapters) / Double(book.chapters.count)
    }
}

// MARK: - Book and chapter models
struct BookDetails {
    let imageName: String
    let title: String
    let author: String
    let description: String
    let chapters: [Chapter]
}

struct Chapter: Identifiable {
    let id = UUID()
    let title: String
    let status: ChapterStatus
}

enum ChapterStatus {
    case read, reading, unread
    
    var iconName: String {
        switch self {
        case .read: return UIKitAssets.imageRead
        case .reading: return UIKitAssets.imageReadingNow
        case .unread: return UIKitAssets.imageReadingNow
        }
    }
    
    var iconColor: Color {
        switch self {
        case .read: return UIKitAssets.setColor(for: UIKitAssets.colorAccentMedium)
        case .reading: return UIKitAssets.setColor(for: UIKitAssets.colorAccentDark)
        case .unread: return UIKitAssets.setColor(for: UIKitAssets.colorBackground)
        }
    }
}

// MARK: - Constants
private extension BookDetailsView {
    enum Constants {
        static let topPadding: CGFloat = 16
        static let sidePadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 20
        
        static let coverHeight: CGFloat = 380
        static let buttonCornerRadius: CGFloat = 8
        
        static let progressBarHeight: CGFloat = 8
        static let progressBarCornerRadius: CGFloat = 4
        
        static let chapterSpacing: CGFloat = 12
        static let chapterIconSize: CGFloat = 20
    }
}

#Preview {
    BookDetailsView(router: Router())
}
