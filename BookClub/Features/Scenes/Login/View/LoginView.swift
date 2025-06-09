//
//  LoginView.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var store: Store<LoginState, LoginAction>

    private let bookCovers = BookCoversMock.getBookCovers(for: .five)

    private let headerTitle = LocalizedKey.loginTitle
    private let headerSubtitle = LocalizedKey.loginSubtitle
    private let emailTitle = LocalizedKey.emailTitle
    private let passwordTitle = LocalizedKey.passwordTitle
    private let signInButtonTitle = LocalizedKey.signInButtonTitle

    var body: some View {
        ZStack(alignment: .top) {
            background

            VStack(spacing: 0) {
                topSpacer
                carousel
                carouselToTitleSpacer
                header
                Spacer()
                inputGroup
                inputToButtonSpacer
                signInButton
                bottomSpacer
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(
                isPresented: Binding(
                get: { store.state.loginError != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.dismissError)
                    }
                }
            )
        ) {
            if let error = store.state.loginError {
                ErrorView(message: error.localizedDescription)
            }
        }
    }
}

private extension LoginView {
    var background: some View {
        Color(Constants.background)
            .ignoresSafeArea()
    }

    var topSpacer: some View {
        Spacer().frame(height: Constants.topPadding)
    }

    var carouselToTitleSpacer: some View {
        Spacer().frame(height: Constants.carouselToTitleSpacing)
    }

    var inputToButtonSpacer: some View {
        Spacer().frame(height: Constants.inputToButtonSpacing)
    }

    var bottomSpacer: some View {
        Spacer().frame(height: Constants.bottomPadding)
    }

    var carousel: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let offset = calculateOffset(for: time, in: geometry.size.width)

                HStack(spacing: Constants.elementSpacing) {
                    ForEach(bookCovers, id: \.imageName) { cover in
                        carouselItem(for: cover)
                    }
                    ForEach(bookCovers.prefix(3)) { cover in
                        carouselItem(for: cover)
                    }
                }
                .offset(x: offset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: Constants.carouselHeight)
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            AuthScreenTitle()
                .text(headerSubtitle.uppercased())
                .font(name: "Alumni Sans Bold", size: Constants.headerTitleFontSize)
                .foregroundColor(Constants.headerTitleColor)
                .lineHeightMultiple(1.0)
                .padding(.bottom, 8)

            AuthScreenTitle()
                .text(headerTitle.uppercased())
                .font(name: "Alumni Sans Bold", size: Constants.headerSubtitleFontSize)
                .foregroundColor(Constants.headerSubtitleColor)
                .lineHeightMultiple(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Constants.sidePadding)
    }

    var inputGroup: some View {
        VStack(spacing: 0) {
            inputField(
                title: emailTitle,
                text: Binding(
                    get: { store.state.email },
                    set: { newEmail in
                        guard store.state.email != newEmail else { return }
                        store.send(.emailChanged(newEmail))
                    }
                ),
                isSecure: false,
                isPasswordField: false
            )

            Divider()
                .background(Constants.inputFieldBorderColor)
                .padding(.leading, Constants.sidePadding)

            inputField(
                title: passwordTitle,
                text: Binding(
                    get: { store.state.password },
                    set: { newPassword in
                        guard store.state.password != newPassword else { return }
                        store.send(.passwordChanged(newPassword))
                    }
                ),
                isSecure: !store.state.isPasswordVisible,
                isPasswordField: true
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: Constants.inputFieldCornerRadius)
                .stroke(Constants.inputFieldBorderColor, lineWidth: 1)
        )
        .padding(.horizontal, Constants.sidePadding)
    }

    func inputField(
        title: String,
        text: Binding<String>,
        isSecure: Bool,
        isPasswordField: Bool
    ) -> some View {
        HStack {
            Text(title)
                .font(Constants.inputFieldTitleFont)
                .foregroundColor(Constants.inputFieldTitleColor)

            if isSecure {
                SecureField("", text: text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(Constants.inputFieldFont)
                    .foregroundColor(Constants.inputFieldTitleColor)
                    .frame(maxWidth: .infinity, minHeight: Constants.inputFieldHeight)
                    .accessibilityIdentifier("securePasswordField")
            } else {
                TextField("", text: text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(Constants.inputFieldFont)
                    .foregroundColor(Constants.inputFieldTitleColor)
                    .frame(maxWidth: .infinity, minHeight: Constants.inputFieldHeight)
                    .accessibilityIdentifier(isPasswordField
                                              ? "visiblePasswordField"
                                              : "emailField")
            }

            if !text.wrappedValue.isEmpty {
                if isPasswordField {
                    Button {
                        store.send(.togglePasswordVisibility)
                    } label: {
                        (store.state.isPasswordVisible
                         ? Constants.hidePasswordImage
                         : Constants.showPasswordImage)
                            .resizable()
                            .frame(width: Constants.iconSize,
                                   height: Constants.iconSize)
                            .foregroundColor(Constants.inputFieldTitleColor)
                    }
                    .accessibilityIdentifier("togglePasswordVisibility")
                } else {
                    Button {
                        store.send(.emailChanged(""))
                    } label: {
                        Constants.clearButtonImage
                            .resizable()
                            .frame(width: Constants.iconSize,
                                   height: Constants.iconSize)
                            .foregroundColor(Constants.inputFieldTitleColor)
                    }
                    .accessibilityIdentifier("clearButton")
                }
            }
        }
        .padding(.horizontal, Constants.sidePadding)
        .frame(height: Constants.inputFieldContainerHeight)
    }

    var signInButton: some View {
        Button {
            store.send(.didLoginButtonTapped)
        } label: {
            Text(signInButtonTitle)
                .font(Constants.buttonFont)
                .foregroundColor(
                    isFormValid
                        ? Constants.buttonActiveTextColor
                        : Constants.buttonInactiveTextColor
                )
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    isFormValid
                        ? Constants.buttonActiveColor
                        : Constants.buttonInactiveColor
                )
                .cornerRadius(Constants.buttonCornerRadius)
        }
        .disabled(!isFormValid || store.state.isLoading)
        .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
        .padding(.horizontal, Constants.sidePadding)
        .accessibilityIdentifier("signInButton")
    }

    var isFormValid: Bool {
        !store.state.isFormValid
    }
}

private extension LoginView {
    func calculateOffset(for time: TimeInterval, in width: CGFloat) -> CGFloat {
        let step = Constants.elementWidth + Constants.elementSpacing
        let totalWidth = step * CGFloat(bookCovers.count)
        let speedFactor: CGFloat = 5.0
        let offset = -CGFloat((time / speedFactor)
                                 .truncatingRemainder(dividingBy: Constants.scrollSpeed))
                         * step
        return offset.truncatingRemainder(dividingBy: totalWidth)
    }

    @ViewBuilder
    func carouselItem(for bookCover: BookCover) -> some View {
        Image(bookCover.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: Constants.elementWidth,
                   height: Constants.elementHeight)
            .clipped()
            .cornerRadius(Constants.elementCornerRadius)
    }
}

private extension LoginView {
    enum Constants {
        @MainActor static let topPadding: CGFloat = 48
        static let bottomPadding: CGFloat = 50
        static let sidePadding: CGFloat = 16
        static let carouselToTitleSpacing: CGFloat = 48
        static let inputToButtonSpacing: CGFloat = 28
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 12
        static let background = AppColors.accentDark

        @MainActor static var carouselHeight: CGFloat {
            UIScreen.main.bounds.height < 700 ? 180 : 270
        }
        @MainActor static var elementHeight: CGFloat {
            carouselHeight
        }
        @MainActor static var elementWidth: CGFloat {
            elementHeight * aspectRatio
        }
        private static let aspectRatio: CGFloat = 172.0 / 270.0
        static let elementCornerRadius: CGFloat = 4
        static let elementSpacing: CGFloat = 8
        static let scrollSpeed: TimeInterval = 30

        @MainActor static var headerTitleFontSize: CGFloat {
            UIScreen.main.bounds.width < 400 ? 36 : 48
        }
        @MainActor static var headerSubtitleFontSize: CGFloat {
            UIScreen.main.bounds.width < 400 ? 72 : 96
        }
        static let headerTitleColor = AppColors.accentLight
        static let headerSubtitleColor = AppColors.secondary

        @MainActor static let inputFieldHeight: CGFloat = 22
        @MainActor static let inputFieldContainerHeight: CGFloat = 44
        static let inputFieldBorderColor = AppColors.accentMedium
        static let inputFieldTitleColor = AppColors.accentMedium
        static let inputFieldCornerRadius: CGFloat = 8
        @MainActor static let inputFieldFont = AppFonts.bodySmall
        @MainActor static let inputFieldTitleFont = AppFonts.bodySmall
        static let iconSize: CGFloat = 16
        static let clearButtonImage = AppImages.close
        static let showPasswordImage = AppImages.eyeOn
        static let hidePasswordImage = AppImages.eyeOff

        static let buttonActiveColor = AppColors.white
        static let buttonInactiveColor = AppColors.accentMedium
        static let buttonActiveTextColor = AppColors.accentDark
        static let buttonInactiveTextColor = AppColors.accentLight
        @MainActor static let buttonFont = AppFonts.body
    }
}

// Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store<LoginState, LoginAction>(
            initialState: .init(),
            reducer: { _, _ in
                return .none
            }
        )
        LoginView(store: store)
    }
}
