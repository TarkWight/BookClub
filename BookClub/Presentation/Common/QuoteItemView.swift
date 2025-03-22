//
//  QuoteItemView.swift
//  BookClub
//
//  Created by Tark Wight on 19.03.2025.
//

import SwiftUI

struct QuoteItemView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“\(quote.text)”")
                .applyFontQuoteAccentDarkStyle()

            Text("\(quote.book) • \(quote.author)")
                .applyFontTextAccentDarkStyle()
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(UIKitAssets.setColor(for: UIKitAssets.colorAccentLight))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}
