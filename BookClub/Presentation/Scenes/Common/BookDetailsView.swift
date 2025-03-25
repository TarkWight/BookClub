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
        image: Image("pl"),
        title: "Код Да Винчи",
        author: "Дэн Браун",
        description: """
        Секретный код скрыт в работах Леонардо да Винчи...

        Только он поможет найти христианские святыни, дающие немыслимые власть и могущество...

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
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.sectionSpacing) {

                    ZStack(alignment: .topLeading) {
                        book.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: Constants.coverHeight)
                            .applyBookDetailsGradientMask()
                            .clipped()
                            .ignoresSafeArea(edges: .top)

                        BackButtonView(action: { router.navigateTo(.mainTab) }, color: .light)
                            .padding(.leading, Constants.sidePadding)
                            .padding(.top, Constants.topPadding)
                    }

                    HStack(spacing: Constants.buttonSpacing) {
                        ActionButton(title: LocalizedKey.readButtonTitle, icon: AppImages.play, width: Constants.readButtonWidth, isPrimary: true, action: {
                            router.navigateTo(.reader)
                        })

                        ActionButton(title: LocalizedKey.addToBookmarkButtonTitle, icon: AppImages.bookmarks, width: Constants.bookmarkButtonWidth, isPrimary: false, action: {
                            print("Книга добавлена в избранное")
                        })
                    }
                    .padding(.horizontal, Constants.sidePadding)
                    .offset(y: -Constants.buttonOverlap)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .applyH1AccentDarkTitleStyle()
                            .foregroundColor(AppColors.accentDark)

                        Text(book.author)
                            .applyFontBodyAccentDarkStyle()
                    }
                    .padding(.horizontal, Constants.sidePadding)

                    Text(book.description)
                        .font(.body)
                        .foregroundColor(AppColors.accentDark)
                        .padding(.horizontal, Constants.sidePadding)

                    VStack(alignment: .leading) {
                        Text(LocalizedKey.progressBarLabel)
                            .applyFontH2AccentDarkStyle()
                        ProgressBarView(progress: progress())
                    }
                    .padding(.horizontal, Constants.sidePadding)

                    VStack(alignment: .leading, spacing: Constants.chapterSpacing) {
                        Text(LocalizedKey.listOfContentsLabel)
                            .applyFontH2AccentDarkStyle()

                        ForEach(book.chapters) { chapter in
                            HStack {
                                Text(chapter.title)
                                    .font(.body)
                                    .foregroundColor(AppColors.accentDark)

                                Spacer()

                               chapter.status.icon
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: Constants.chapterIconSize, height: Constants.chapterIconSize)
                                    .foregroundColor(chapter.status.iconColor)
                            }
                            .frame(height: Constants.chapterRowHeight)
                        }
                    }
                    .padding(.horizontal, Constants.sidePadding)

                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    private func progress() -> Double {
        let readChapters = book.chapters.filter { $0.status == .read }.count
        return Double(readChapters) / Double(book.chapters.count)
    }

    // MARK: - Action Button
    struct ActionButton: View {
        let title: String
        let icon: Image
        let width: CGFloat
        let isPrimary: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Constants.iconSize, height: Constants.iconSize)

                    Text(title)
                        .font(.body)
                        .bold()
                }
                .frame(width: width, height: Constants.buttonHeight)
                .foregroundColor(isPrimary ? AppColors.white : AppColors.accentDark)
                .background(isPrimary ? AppColors.accentDark : AppColors.white)
                .cornerRadius(Constants.buttonCornerRadius)
            }
        }
    }
}

// MARK: - Book and Chapter Models
struct BookDetails {
    let image: Image
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

    var icon: Image {
        switch self {
        case .read: return AppImages.read
        case .reading: return AppImages.readingNow
        case .unread: return AppImages.readingNow
        }
    }

    var iconColor: Color {
        switch self {
        case .read: return AppColors.accentMedium
        case .reading: return AppColors.accentDark
        case .unread: return AppColors.background
        }
    }
}

// MARK: - Constants
private extension BookDetailsView {
    enum Constants {
        static let topPadding: CGFloat = 66
        static let sidePadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 20

        static let coverHeight: CGFloat = 380
        static let readButtonWidth: CGFloat = 189
        static let bookmarkButtonWidth: CGFloat = 173
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 12
        static let buttonSpacing: CGFloat = 16
        static let buttonOverlap: CGFloat = 25

        static let progressBarHeight: CGFloat = 8
        static let progressBarCornerRadius: CGFloat = 4

        static let chapterSpacing: CGFloat = 12
        static let chapterRowHeight: CGFloat = 48
        static let chapterIconSize: CGFloat = 20

        static let iconSize: CGFloat = 18
    }
}

#Preview {
    BookDetailsView(router: Router())
}
