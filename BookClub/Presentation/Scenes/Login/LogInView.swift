//
//  LogInView.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

struct LogInView: View {
    @ObservedObject var router: Router

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

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
    }
}

// MARK: - UI Components
private extension LogInView {
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
                    ForEach(bookCovers + bookCovers.prefix(3)) { bookCover in
                        Image(bookCover.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: Constants.elementWidth, height: Constants.elementHeight)
                            .clipped()
                            .cornerRadius(Constants.elementCornerRadius)
                    }
                }
                .offset(x: offset)
            }
        }
        .frame(height: Constants.carouselHeight)
    }

    var header: some View {
        VStack(alignment: .leading) {
            Text(headerSubtitle)
                .font(Constants.headerTitleFont)
                .foregroundColor(Constants.headerTitleColor)

            ForEach(["КНИЖНЫЙ", "МИР"], id: \.self) { line in
                Text(line)
                    .applyNegativeSpacing(
                        font: Constants.headerSubtitleFont,
                        color: Constants.headerSubtitleColor,
                        spacingType: .subtitleLines
                    )
            }
        }
        .padding(.horizontal, Constants.sidePadding)
    }

    var inputGroup: some View {
        VStack(spacing: 0) {
            inputField(title: emailTitle, text: $email, isSecure: false, isPasswordField: false)

            Divider().background(Constants.inputFieldBorderColor).padding(.leading, Constants.sidePadding)
            inputField(title: passwordTitle, text: $password, isSecure: !isPasswordVisible, isPasswordField: true)
        }
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.inputFieldCornerRadius)
                .stroke(Constants.inputFieldBorderColor, lineWidth: 1)
        )
        .padding(.horizontal, Constants.sidePadding)
    }

    func inputField(title: String, text: Binding<String>, isSecure: Bool, isPasswordField: Bool) -> some View {
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
                    .multilineTextAlignment(.leading)
                    .accessibilityIdentifier("securePasswordField")
            } else {
                TextField("", text: text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(Constants.inputFieldFont)
                    .foregroundColor(Constants.inputFieldTitleColor)
                    .frame(maxWidth: .infinity, minHeight: Constants.inputFieldHeight)
                    .multilineTextAlignment(.leading)
                    .accessibilityIdentifier(isPasswordField ? "visiblePasswordField" : "emailField")
            }

            if !text.wrappedValue.isEmpty {
                if isPasswordField {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        (isPasswordVisible ? Constants.hidePasswordImage : Constants.showPasswordImage)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .foregroundColor(Constants.inputFieldTitleColor)
                    }
                    .accessibilityIdentifier("togglePasswordVisibility")
                } else {
                    Button {
                        text.wrappedValue = ""
                    } label: {
                        Constants.clearButtonImage
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
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
            router.navigateTo(.mainTab)
        } label: {
            Text(signInButtonTitle)
                .font(Constants.buttonFont)
                .foregroundColor(isFormValid ? Constants.buttonActiveTextColor : Constants.buttonInactiveTextColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Constants.buttonActiveColor : Constants.buttonInactiveColor)
                .cornerRadius(Constants.buttonCornerRadius)
        }
        .disabled(!isFormValid)
        .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
        .padding(.horizontal, Constants.sidePadding)
        .accessibilityIdentifier("signInButton")
    }

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
}

// MARK: - Private methods
private extension LogInView {
    func calculateOffset(for time: TimeInterval, in width: CGFloat) -> CGFloat {
        let step = Constants.elementWidth + Constants.elementSpacing
        let totalWidth = step * CGFloat(bookCovers.count)
        let speedFactor: CGFloat = 5.0
        let offset = -CGFloat((time / speedFactor).truncatingRemainder(dividingBy: Constants.scrollSpeed)) * step

        return offset.truncatingRemainder(dividingBy: totalWidth)
    }
}

// MARK: - Constants
private extension LogInView {
    enum Constants {

        // MARK: - Constraints

        @MainActor
        static let topPadding: CGFloat = UIScreen.main.bounds.height < 700 ? 40 : 98

        static let bottomPadding: CGFloat = 50
        static let sidePadding: CGFloat = 16

        static let carouselHeight: CGFloat = 270
        static let carouselToTitleSpacing: CGFloat = 48

        static let headerHeight: CGFloat = 210
        static let titleToInputSpacing: CGFloat = 32

        static let inputGroupHeight: CGFloat = 88
        static let inputToButtonSpacing: CGFloat = 28

        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 12

        static let background = AppColors.accentDark

        // MARK: - Carousel

        static let elementWidth: CGFloat = 172
        static let elementHeight: CGFloat = 270
        static let elementCornerRadius: CGFloat = 4
        static let elementSpacing: CGFloat = 8
        static let scrollSpeed: TimeInterval = 30

        // MARK: - Header

        static let headerTitleColor = AppColors.accentLight
        static let headerSubtitleColor = AppColors.secondary

        @MainActor
        static let headerTitleFont = AppFonts.header1
        @MainActor
        static let headerSubtitleFont = AppFonts.title

        // MARK: - Input Fields

        static let inputFieldTitleColor = AppColors.accentMedium
        static let inputFieldBorderColor = AppColors.accentMedium
        static let inputFieldCornerRadius: CGFloat = 8
        static let inputFieldHeight: CGFloat = 22
        static let inputFieldContainerHeight: CGFloat = 44
        static let iconSize: CGFloat = 16

        static let clearButtonImage = AppImages.close
        static let showPasswordImage = AppImages.eyeOn
        static let hidePasswordImage = AppImages.eyeOff

        @MainActor
        static let inputFieldFont = AppFonts.bodySmall
        @MainActor
        static let inputFieldTitleFont = AppFonts.bodySmall

        // MARK: - Button

        static let buttonActiveColor = AppColors.white
        static let buttonInactiveColor = AppColors.accentMedium
        static let buttonActiveTextColor = AppColors.accentDark
        static let buttonInactiveTextColor = AppColors.accentLight

        @MainActor
        static let buttonFont = AppFonts.body
    }
}

#Preview {
    LogInView(router: Router())
}
