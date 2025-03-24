//
//  ChaptersView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct ChaptersView: View {
    @EnvironmentObject var session: ReadingSession
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: .background))
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                BackButtonView(action: { isPresented = false }, color: .dark)

                Text(LocalizedKey.chaptersLabel)
                    .applyFontH2AccentDarkStyle()
                    .padding(.top, 10)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(session.fetchChapters()) { chapter in
                            Button {
                                Task {
                                    await session.startFromChapter(chapter)
                                    isPresented = false
                                }
                            } label: {
                                HStack {
                                    Text(chapter.title)
                                        .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}


#Preview {
    ChaptersView(isPresented: .constant(true))
        .environmentObject(ReadingSession(chunkManager: TextChunkManager()))
}
