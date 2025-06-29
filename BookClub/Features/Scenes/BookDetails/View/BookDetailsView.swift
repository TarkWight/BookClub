//
//  BookDetailsView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookDetailsView: View {
    @ObservedObject var store: Store<BookDetailsState, BookDetailsAction>

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
                .padding(.horizontal, Constants.sidePadding)
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }

    // MARK: – Header

    private var headerImage: some View {
           ZStack(alignment: .topLeading) {
               // Если есть URL обложки — грузим её асинхронно
               if let url = store.state.coverURL {
                   AsyncImage(url: url) { phase in
                       switch phase {
                       case .empty:
                           // Placeholder
                           Color.gray.opacity(0.2)
                       case .success(let image):
                           image
                               .resizable()
                               .scaledToFill()
                       case .failure:
                           // Паддинг-запасной вариант
                           Color.red.opacity(0.1)
                       @unknown default:
                           Color.gray
                       }
                   }
                   .frame(height: Constants.coverHeight)
                   .clipped()
                   .applyBookDetailsGradientMask()
               } else {
                   // Фолбэк: локальная картинка
                   AppImages.error
                       .resizable()
                       .aspectRatio(contentMode: .fill)
                       .frame(height: Constants.coverHeight)
                       .applyBookDetailsGradientMask()
                       .clipped()
               }

               BackButtonView(
                action: { store.send(.backButtonTapped) },
                   color: .light
               )
               .padding(.top, Constants.topPadding)
           }
       }
    // MARK: – Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Constants.buttonSpacing) {
            // Read / Download
            let downloadState = store.state.bookDownload
            ActionButton(
                title: downloadState == .loaded([])
                    ? LocalizedKey.readButtonTitle
                    : LocalizedKey.downloadButtonTitle,
                icon: downloadState == .loaded([])
                    ? AppImages.play : AppImages.download,
                isPrimary: true
            ) {
                switch store.state.bookDownload {
                case .loaded:
                    store.send(.startReadingTapped)
                case .idle, .loading, .failure:
                    store.send(.downloadBookTapped)
                }
            }

            // Favorite toggle
            ActionButton(
                title: store.state.isFavorite
                    ? LocalizedKey.removeFromFavoritesTitle
                    : LocalizedKey.addToBookmarkButtonTitle,
                icon: AppImages.bookmarks,
                isPrimary: false
            ) {
                store.send(.toggleFavoriteTapped)
            }
        }
        .offset(y: -Constants.buttonOverlap)
    }

    // MARK: – Book Info

    private var bookInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(store.state.title)
                .applyH1AccentDarkTitleStyle()
            Text(store.state.author)
                .applyFontBodyAccentDarkStyle()
        }
    }

    private var bookDescription: some View {
        Text(store.state.description)
            .font(.body)
            .foregroundColor(AppColors.accentDark)
    }

    // MARK: – Progress

    private var readingProgress: some View {
        VStack(alignment: .leading) {
            Text(LocalizedKey.progressBarLabel)
                .applyFontH2AccentDarkStyle()
            ProgressBarView(progress: store.state.progress)
        }
    }

    // MARK: – Chapters List

    private var chapterList: some View {
        VStack(alignment: .leading, spacing: Constants.chapterSpacing) {
            Text(LocalizedKey.listOfContentsLabel)
                .applyFontH2AccentDarkStyle()

            ForEach(store.state.chapters) { chapter in
                HStack {
                    Text(chapter.title)
                        .font(.body)
                        .foregroundColor(AppColors.accentDark)
                    Spacer()
                    (chapter.order == store.state.selectedChapterOrder
                        ? AppImages.readingNow
                        : (chapter.status == .completed
                            ? AppImages.read
                            : AppImages.readingNow))
                        .resizable()
                        .frame(
                            width: Constants.chapterIconSize,
                            height: Constants.chapterIconSize
                        )
                        .foregroundColor(
                            chapter.order == store.state.selectedChapterOrder
                                ? AppColors.accentDark
                                : (chapter.status == .completed
                                    ? AppColors.accentMedium
                                    : AppColors.background)
                        )
                }
                .frame(height: Constants.chapterRowHeight)
                .onTapGesture {
                    store.send(.chapterTapped(order: chapter.order))
                }
            }
        }
    }
}

// MARK: – ActionButton

private struct ActionButton: View {
    let title: String
    let icon: Image
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                icon
                    .resizable()
                    .renderingMode(.template)
                    .frame(
                        width: Constants.iconSize,
                        height: Constants.iconSize
                    )
                Text(title)
                    .font(.body).bold()
            }
            .frame(height: Constants.buttonHeight)
            .foregroundColor(
                isPrimary
                    ? AppColors.white
                    : AppColors.accentDark
            )
            .frame(maxWidth: .infinity)
            .background(
                isPrimary
                    ? AppColors.accentDark
                    : AppColors.white
            )
            .cornerRadius(Constants.buttonCornerRadius)
        }
    }
}

// MARK: – Constants

private enum Constants {
    static let topPadding: CGFloat = 66
    static let sidePadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let coverHeight: CGFloat = 380

    static let readButtonWidth: CGFloat = .infinity
    static let bookmarkButtonWidth: CGFloat = .infinity

    static let buttonHeight: CGFloat = 50
    static let buttonCornerRadius: CGFloat = 12
    static let buttonSpacing: CGFloat = 16
    static let buttonOverlap: CGFloat = 25

    static let chapterSpacing: CGFloat = 12
    static let chapterRowHeight: CGFloat = 48
    static let chapterIconSize: CGFloat = 20

    static let iconSize: CGFloat = 18
}
