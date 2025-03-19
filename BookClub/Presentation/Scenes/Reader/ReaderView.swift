//
//  ReaderView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct ReaderView: View {
    @ObservedObject var router: Router
    @Binding var isChaptersPresented: Bool

    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            
        VStack {
            BackButtonView(action: { router.navigateTo(.mainTab) }, title: LocalizedKey.backButtonTitle, color: .dark)
            
            Spacer()
        }
    }
    }
}
