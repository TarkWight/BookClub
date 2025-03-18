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
        VStack {
            BackButtonView(action: { router.navigateTo(.mainTab) }, title: LocalizedKey.backButtonTitle)
            
            Spacer()
        }
    }
}
