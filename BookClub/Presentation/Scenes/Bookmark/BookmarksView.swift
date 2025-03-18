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
        VStack {
            Text(LocalizedKey.bookmarksLabel)
                .font(.title)
                .padding(.top, 20)
            
            Spacer()
        }
    }
}
