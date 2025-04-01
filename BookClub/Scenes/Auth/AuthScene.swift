//
//  AuthScene.swift
//  BookClub
//
//  Created by Tark Wight on 30.03.2025.
//

import SwiftUI

struct AuthScene: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            AppColors.accentDark.ignoresSafeArea()
            CredentialInputView(email: $email, password: $password)
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    AuthScene()
}
