//
//  BookmarksView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookmarksView: View {
    @ObservedObject var router: Router

    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text(LocalizedKey.bookmarksLabel)
                    .applyFontH1SecondaryStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 26)
                    .padding(.leading, 16)


                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview  {
    BookmarksView(router: Router())
}
