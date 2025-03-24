//
//  ReaderView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

import SwiftUI

struct ReaderView: View {
    @EnvironmentObject var chunkManager: TextChunkManager
    @ObservedObject var router: Router
    @Binding var isChaptersPresented: Bool

    @State private var isPlaying = false
    @State private var isSettingsPresented = false

    @State private var fontSize: CGFloat = 16
    @State private var lineSpacing: CGFloat = 8

    var body: some View {
        ZStack {
            backgroundColor
            content
        }
        .onAppear {
            Task {
                await chunkManager.loadInitialChunkSet()
            }
        }
        .sheet(isPresented: $isChaptersPresented) {
            ChaptersView(isPresented: $isChaptersPresented)
        }
        .sheet(isPresented: $isSettingsPresented) {
            settingsSheet
                .presentationDetents([.height(Constants.settingsSheetHeight)])
        }
    }
}

// MARK: - UI Components
private extension ReaderView {
    var backgroundColor: some View {
        Color(UIKitAssets.setColor(for: .background))
            .ignoresSafeArea()
    }

    var content: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, Constants.topPadding)
                .padding(.horizontal, Constants.sidePadding)

            scrollView

            toolbar
                .frame(height: Constants.toolbarHeight)
                .background(UIKitAssets.setColor(for: .accentDark))
        }
    }

    var scrollView: some View {
        ScrollView {
            chunkList
        }
    }

    var chunkList: some View {
        LazyVStack(alignment: .leading, spacing: lineSpacing) {
            ForEach(chunkManager.currentChunks, id: \.id) { chunk in
                Text(chunk.text)
                    .font(.system(size: fontSize))
                    .lineSpacing(lineSpacing)
                    .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                    .padding(.horizontal, Constants.sidePadding)
                    .onAppear {
                        if chunk == chunkManager.currentChunks.last {
                            Task {
                                await chunkManager.loadNextChunkIfNeeded()
                            }
                        }
                    }
            }
        }
        .padding(.top, Constants.sidePadding)
        .padding(.bottom, Constants.sidePadding + Constants.toolbarHeight)
    }
}

private extension ReaderView {
    
    var header: some View {
        HStack {
            BackButtonView(action: { router.navigateTo(.mainTab) }, color: .dark)

            Spacer()

            VStack(spacing: Constants.headerSpacing) {
                Text("Код Да Винчи")
                    .applyFontH2AccentDarkStyle()
                Text("Глава 5")
                    .applyFontBodySmallAccentDarkStyle()
            }
            .frame(maxWidth: .infinity)

            Spacer()
                .frame(width: Constants.fakeTrailingWidth)
        }
    }

    var toolbar: some View {
        HStack {
            HStack(spacing: Constants.controlButtonSpacing) {
                ReaderIconButton(image: UIKitAssets.setImage(for: .previous)) { print("Prev") }
                ReaderIconButton(image: UIKitAssets.setImage(for: .contents)) { isChaptersPresented = true }
                ReaderIconButton(image: UIKitAssets.setImage(for: .next)) { print("Next") }
                ReaderIconButton(image: UIKitAssets.setImage(for: .settings)) { isSettingsPresented = true }
            }
            .frame(width: Constants.controlGroupWidth, height: Constants.controlButtonSize)
            .padding(.leading, Constants.sidePadding)
            .padding(.top, Constants.sidePadding)

            Spacer()

            Button(action: {
                isPlaying.toggle()
            }) {
                UIKitAssets.setImage(for: isPlaying ? .pause : .play)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                    .frame(width: 24, height: 24)
            }
            .frame(width: Constants.playButtonSize, height: Constants.playButtonSize)
            .background(UIKitAssets.setColor(for: .accentLight))
            .clipShape(Circle())
            .padding(.trailing, Constants.sidePadding)
            .padding(.top, Constants.sidePadding)
        }
    }

    var settingsSheet: some View {
        VStack(spacing: 24) {
            HStack {
                Text(LocalizedKey.readerSettingsLabel)
                    .applyFontH2AccentDarkStyle()

                Spacer()

                Button(action: { isSettingsPresented = false }) {
                    UIKitAssets.setImage(for: .close)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 30, height: 30)
                        .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                }
            }

            settingRow(
                title: LocalizedKey.readerFontSizeLabel,
                value: "\(Int(fontSize)) " + LocalizedKey.readerPTLabel,
                increment: { fontSize += 1 },
                decrement: { fontSize = max(10, fontSize - 1) }
            )

            settingRow(
                title: LocalizedKey.readerStringSpacingLabel,
                value: "\(Int(lineSpacing)) " + LocalizedKey.readerPTLabel,
                increment: { lineSpacing += 1 },
                decrement: { lineSpacing = max(0, lineSpacing - 1) }
            )

            Spacer()
        }
        .padding()
        .background(UIKitAssets.setColor(for: .background))
    }

    func settingRow(title: String, value: String, increment: @escaping () -> Void, decrement: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .applyFontBodyAccentDarkStyle()

            HStack {
                Text(value)
                    .applyFontBodySmallAccentDarkStyle()

                Spacer()

                HStack(spacing: 0) {
                    Button(action: increment) {
                        UIKitAssets.setImage(for: .increment)
                            .frame(width: Constants.settingsButtonWidth, height: Constants.settingsButtonHeight)
                            .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                    }

                    Divider()
                        .frame(width: Constants.dividerWidth, height: Constants.dividerHeight)
                        .background(UIKitAssets.setColor(for: .accentDark))

                    Button(action: decrement) {
                        UIKitAssets.setImage(for: .decrement)
                            .frame(width: Constants.settingsButtonWidth, height: Constants.settingsButtonHeight)
                            .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                    }
                }
                .background(UIKitAssets.setColor(for: .accentMedium))
                .cornerRadius(Constants.settingsButtonCornerRadius)
            }
        }
    }
}

// MARK: - Icon Button Component
struct ReaderIconButton: View {
    let image: Image
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            image
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(UIKitAssets.setColor(for: .white))
        }
        .frame(width: ReaderView.Constants.controlButtonSize, height: ReaderView.Constants.controlButtonSize)
    }
}

// MARK: - Constants
private extension ReaderView {
    enum Constants {
        /// Layout
        static let sidePadding: CGFloat = 16
        static let topPadding: CGFloat = 16

        /// Header
        static let headerSpacing: CGFloat = 4
        static let fakeTrailingWidth: CGFloat = 80

        /// Scroll/Text
        static let toolbarHeight: CGFloat = 74

        /// Toolbar Buttons
        static let controlGroupWidth: CGFloat = 200
        static let controlButtonSize: CGFloat = 44
        static let controlButtonSpacing: CGFloat = 8
        static let playButtonSize: CGFloat = 40

        /// Settings Sheet
        static let settingsSheetHeight: CGFloat = 256
        static let settingsButtonWidth: CGFloat = 47
        static let settingsButtonHeight: CGFloat = 32
        static let settingsButtonCornerRadius: CGFloat = 8
        static let dividerWidth: CGFloat = 1
        static let dividerHeight: CGFloat = 18
    }
}

#Preview {
    ReaderView(router: Router(), isChaptersPresented: .constant(false))
}
