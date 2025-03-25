//
//  BookDetailsView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookDetailsView: View {
    @ObservedObject var router: Router
    @EnvironmentObject var readingSession: ReadingSession

    var body: some View {
        ZStack {
            Color(AppColors.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
                    headerImage
                    actionButtons
                    bookInfo
                    bookDescription
                    readingProgress
                    chapterList
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - UI Components

    private var headerImage: some View {
        ZStack(alignment: .topLeading) {
            Image("pl")
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
    }

    private var actionButtons: some View {
        HStack(spacing: Constants.buttonSpacing) {
            ActionButton(
                title: LocalizedKey.readButtonTitle,
                icon: AppImages.play,
                width: Constants.readButtonWidth,
                isPrimary: true,
                action: {
                    Task {
                        await readingSession.startFromLastRead()
                        router.navigateTo(.reader)
                    }
                }
            )

            ActionButton(
                title: LocalizedKey.addToBookmarkButtonTitle,
                icon: AppImages.bookmarks,
                width: Constants.bookmarkButtonWidth,
                isPrimary: false,
                action: {
                    print("Добавлено в избранное")
                }
            )
        }
        .padding(.horizontal, Constants.sidePadding)
        .offset(y: -Constants.buttonOverlap)
    }

    private var bookInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Код Да Винчи")
                .applyH1AccentDarkTitleStyle()

            Text("Дэн Браун")
                .applyFontBodyAccentDarkStyle()
        }
        .padding(.horizontal, Constants.sidePadding)
    }

    private var bookDescription: some View {
        Text("""
        Секретный код скрыт в работах Леонардо да Винчи...

        Только он поможет найти христианские святыни, дающие немыслимые власть и могущество...

        Ключ к величайшей тайне, над которой человечество билось веками, наконец может быть найден...
        """)
        .font(.body)
        .foregroundColor(AppColors.accentDark)
        .padding(.horizontal, Constants.sidePadding)
    }

    private var readingProgress: some View {
        VStack(alignment: .leading) {
            Text(LocalizedKey.progressBarLabel)
                .applyFontH2AccentDarkStyle()

            ProgressBarView(progress: progress())
        }
        .padding(.horizontal, Constants.sidePadding)
    }

    private var chapterList: some View {
        let chapters = readingSession.fetchChapters()
        _ = readingSession.chapter(for: readingSession.getCurrentChunkIndex())

        return VStack(alignment: .leading, spacing: Constants.chapterSpacing) {
            Text(LocalizedKey.listOfContentsLabel)
                .applyFontH2AccentDarkStyle()

            ForEach(chapters) { chapter in
                HStack {
                    Text(chapter.title)
                        .font(.body)
                        .foregroundColor(AppColors.accentDark)

                    Spacer()

                    let icon = iconForChapter(chapter)
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Constants.chapterIconSize, height: Constants.chapterIconSize)
                        .foregroundColor(colorForChapter(chapter))
                }
                .frame(height: Constants.chapterRowHeight)
                .onTapGesture {
                    Task {
                        await readingSession.startFromChapter(chapter)
                        router.navigateTo(.reader)
                    }
                }
            }
        }
        .padding(.horizontal, Constants.sidePadding)
    }
}

    // MARK: - Logic
private extension BookDetailsView {
    func progress() -> Double {
        let chapters = readingSession.fetchChapters()
        let currentIndex = readingSession.getCurrentChunkIndex()
        let readCount = chapters.filter { $0.chunkIndex < currentIndex }.count
        return Double(readCount) / Double(chapters.count)
    }

    func iconForChapter(_ chapter: BookChapter) -> Image {
        let currentChunk = readingSession.getCurrentChunkIndex()

        if chapter.chunkIndex == currentChunk {
            return AppImages.readingNow
        } else if chapter.chunkIndex < currentChunk {
            return AppImages.read
        } else {
            return AppImages.readingNow
        }
    }

    func colorForChapter(_ chapter: BookChapter) -> Color {
        let currentChunk = readingSession.getCurrentChunkIndex()

        if chapter.chunkIndex == currentChunk {
            return AppColors.accentDark
        } else if chapter.chunkIndex < currentChunk {
            return AppColors.accentMedium
        } else {
            return AppColors.background
        }
    }
}

// MARK: - UI Components

extension BookDetailsView {
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
        .environmentObject(ReadingSession(chunkManager: TextChunkManager()))
}
