//
//  AuthScene+CredentialInputView.swift
//  BookClub
//
//  Created by Tark Wight on 29.03.2025.
//

import SwiftUI

extension AuthScene {

    // MARK: - CredentialInputViewConfiguration Struct

    struct CredentialInputViewConfiguration {
        var emailLabel: String = LocalizedKey.emailLabel
        var passwordLabel: String = LocalizedKey.passwordLabel
        var foregroundColor: Color = AppColors.accentLight
        var backgroundColor: Color = .clear
        var cornerRadius: CGFloat = 10
        var leftPadding: CGFloat = 16
        var borderWidth: CGFloat = 1
        var passwordPlaceholder: String = ""
        var emailPlaceholder: String = ""
        var fontName: String = AppFonts.bodySmall
        var fontSize: CGFloat = 14
    }

    // MARK: - CredentialInputView

    struct CredentialInputView: View {
        @Binding var email: String
        @Binding var password: String

        @State private var isPasswordVisible: Bool = false
//        @State private var isEmailEmpty: Bool = true
//        @State private var isPasswordEmpty: Bool = true

        var config: CredentialInputViewConfiguration = .init()

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                emailTextField(label: config.emailLabel)
                dividerView()
                passwordTextField(label: config.passwordLabel)
            }
            .padding(.leading, config.leftPadding)
            .background(config.backgroundColor)
            .cornerRadius(config.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.foregroundColor, lineWidth: config.borderWidth)
            )
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }

        // MARK: - Email TextField

        func emailTextField(label: String) -> some View {
            HStack {
                Text(label)
                    .applyFontStyle(.bodySmall, color: config.foregroundColor)
                    .frame(width: CredInputFieldConstants.titleWidth, alignment: .leading)

                TextField(config.emailPlaceholder, text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.custom(config.fontName, size: config.fontSize))
                    .padding(.leading, config.leftPadding)
                    .foregroundColor(config.foregroundColor)
                    .accessibilityIdentifier("emailTextField")

                if !email.isEmpty {
                    clearButton(text: $email)
                        .padding(.trailing, CredInputFieldConstants.sidePadding)
                        .accessibilityIdentifier("clearButton")
                }
            }
            .frame(height: CredInputFieldConstants.fieldHeight)
        }

        // MARK: - Password TextField

        func passwordTextField(label: String) -> some View {
            HStack {
                Text(label)
                    .applyFontStyle(.bodySmall, color: config.foregroundColor)
                    .frame(width: CredInputFieldConstants.titleWidth, alignment: .leading)

                if isPasswordVisible {
                    TextField(config.passwordPlaceholder, text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.leading, config.leftPadding)
                        .foregroundColor(config.foregroundColor)
                        .accessibilityIdentifier("passwordTextField")
                } else {
                    SecureField(config.passwordPlaceholder, text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.leading, config.leftPadding)
                        .foregroundColor(config.foregroundColor)
                        .accessibilityIdentifier("secureTextField")
                }

                if !password.isEmpty {
                    secureButton()
                        .padding(.trailing, CredInputFieldConstants.sidePadding)
                        .accessibilityIdentifier("secureButton")
                }
            }
            .frame(height: CredInputFieldConstants.fieldHeight)
        }

        // MARK: - Clear Button

        func clearButton(text: Binding<String>) -> some View {
            Button {
                text.wrappedValue = ""
            } label: {
                AppImages.close
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(config.foregroundColor)
                    .frame(width: CredInputFieldConstants.imageSize, height: CredInputFieldConstants.imageSize)
            }
        }

        // MARK: - Secure Toggle Button

        func secureButton() -> some View {
            Button {
                isPasswordVisible.toggle()
            } label: {
                (isPasswordVisible ? AppImages.eyeOn : AppImages.eyeOff)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(config.foregroundColor)
                    .frame(width: CredInputFieldConstants.imageSize, height: CredInputFieldConstants.imageSize)
            }
        }

        // MARK: - Divider

        func dividerView() -> some View {
            Divider()
                .background(config.foregroundColor)
        }

        // MARK: - Constants

        enum CredInputFieldConstants {
            static let fieldHeight: CGFloat = 44
            static let sidePadding: CGFloat = 16
            static let titleWidth: CGFloat = 100
            static let imageSize: CGFloat = 20
        }
    }
}
