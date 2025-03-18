//
//  BookDetailsView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct BookDetailsView: View {
    @ObservedObject var router: Router

    var body: some View {
        ZStack {
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            VStack {
                BackButtonView(action: { router.navigateTo(.mainTab) }, title: LocalizedKey.backButtonTitle)
                
                Spacer()
            }
        }
    }
}
