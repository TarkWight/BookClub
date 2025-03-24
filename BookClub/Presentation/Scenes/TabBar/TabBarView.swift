//
//  TabBarView.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedTab: Tab
    let onTabSelected: (Tab) -> Void
    let onReadSelected: () -> Void
    let onLogout: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                HStack(spacing: 0) {
                    tabButton(.library)
                    tabButton(.search)
                }

                Spacer()

                HStack(spacing: 0) {
                    tabButton(.bookmarks)
                    logoutButton()
                }
            }
            .frame(height: Constants.tabBarHeight)
            .padding(.horizontal, Constants.horizontalPadding)
            .background(UIKitAssets.setColor(for: .accentDark))
            .clipShape(Capsule())

            Button(action: { onReadSelected() }) {
                UIKitAssets.setImage(for: .play)
                    .resizable()
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundColor(UIKitAssets.setColor(for: .accentDark))
                    .frame(width: Constants.playButtonSize, height: Constants.playButtonSize)
                    .background(UIKitAssets.setColor(for: .accentDark))
                    .clipShape(Circle())
            }
            .position(x: (UIScreen.main.bounds.width - Constants.horizontalPadding * 2) / 2,
                      y: Constants.playButtonOffsetY)
        }
        .frame(height: Constants.tabBarTotalHeight)
        
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab) -> some View {
        Button(action: { onTabSelected(tab) }) {
            VStack {
                UIKitAssets.setImage(for: tab.icon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundColor(selectedTab == tab
                                     ? UIKitAssets.setColor(for: .white)
                                     : UIKitAssets.setColor(for: .accentMedium))
            }
            .frame(width: Constants.tabSize, height: Constants.tabSize)
        }
    }

    @ViewBuilder
    private func logoutButton() -> some View {
        Button(action: { onLogout() }) {
            VStack {
                UIKitAssets.setImage(for: .logOut)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundColor(UIKitAssets.setColor(for: .accentMedium))
            }
            .frame(width: Constants.tabSize, height: Constants.tabSize)
        }
    }
}

// MARK: - Constants

private extension TabBarView {
    enum Constants {
        static let tabBarHeight: CGFloat = 64
        static let tabBarTotalHeight: CGFloat = 80
        static let horizontalPadding: CGFloat = 16

        static let tabSize: CGFloat = 64
        static let iconSize: CGFloat = 24

        static let playButtonSize: CGFloat = 80
        static let playButtonOffsetY: CGFloat = 48

        static let tabBarBackgroundColor = UIKitAssets.setColor(for: .accentDark)
        static let selectedTabColor = UIKitAssets.setColor(for: .white)
        static let unselectedTabColor = UIKitAssets.setColor(for: .accentMedium)

        static let playButtonIconColor = UIKitAssets.setColor(for: .white)
        static let playButtonBackgroundColor = UIKitAssets.setColor(for: .secondary)
    }
}

#Preview {
    TabBarView(
        selectedTab: .constant(.library),
        onTabSelected: { _ in },
        onReadSelected: { },
        onLogout: { }
    )
    .padding(.horizontal, TabBarView.Constants.horizontalPadding)
}
