//
//  ChaptersView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct ChaptersView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            BackButtonView(action: { isPresented = false }, title: LocalizedKey.backButtonTitle)
            
            Text(LocalizedKey.chaptersLabel)
                .font(.title)
                .padding(.top, 10)

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
