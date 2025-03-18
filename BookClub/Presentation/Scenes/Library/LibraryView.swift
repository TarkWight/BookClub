//
//  LibraryView.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var router: Router

    var body: some View {
        
        ZStack {
            Color(UIKitAssets.setColor(for: UIKitAssets.colorBackground))
                .ignoresSafeArea()
            
            VStack {
                Text(LocalizedKey.libraryLabel)
                    .applyTextLabelStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 26)
                    .padding(.leading, 16)
                
                Spacer()
            }
        }
    }
}
