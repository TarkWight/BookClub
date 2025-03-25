//
//  LogInView.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

struct LogInView: View {
    @ObservedObject var router: Router

    let bookCovers = BookCoversMock.getBookCovers(for: .five)
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isAnimating = false

    @State private var headerTitle = LocalizedKey.loginTitle
    @State private var headerSubtitle = LocalizedKey.loginSubtitle
    @State private var emailTitle = LocalizedKey.emailTitle
    @State private var passwordTitle = LocalizedKey.passwordTitle
    @State private var signInButtonTitle = LocalizedKey.signInButtonTitle

    let buttonFont = AppFonts.body
    let inputFieldTitleFont = AppFonts.bodySmall
    let inputFieldFont = AppFonts.bodySmall
    let headerTitleFont = AppFonts.header1
    let headerSubtitleFont = AppFonts.title
    let background = AppColors.accentDark

    var body: some View {
        ZStack(alignment: .top) {
            Color(background)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: Constants.topPadding)

                carousel
                    .frame(maxWidth: .infinity, maxHeight: Constants.carouselHeight)

                Spacer().frame(height: Constants.carouselToTitleSpacing)

                header
                    .padding(.horizontal, Constants.sidePadding)

                Spacer()

                inputFields
                    .padding(.horizontal, Constants.sidePadding)

                Spacer()
                    .frame(height: Constants.inputToButtonSpacing)

                signInButton
                    .padding(.horizontal, Constants.sidePadding)

                Spacer()
                    .frame(height: Constants.bottomPadding)
            }
            .ignoresSafeArea(.all)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - LogInView content
private extension LogInView {
    var carousel: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let offset = calculateOffset(for: time, in: geometry.size.width)

                HStack(spacing: Constants.elementSpacing) {
                    ForEach(bookCovers) { bookCover in
                        Image(bookCover.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: Constants.elementWidth, height: Constants.elementHeight)
                            .clipped()
                            .cornerRadius(Constants.elementCornerRadius)
                    }

                    ForEach(bookCovers.prefix(3)) { bookCover in
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
        .frame(maxWidth: .infinity, maxHeight: Constants.carouselHeight)
    }

    var header: some View {
        VStack(alignment: .leading) {
            Text(headerSubtitle)
                .font(headerTitleFont)
                .foregroundColor(Constants.headerTitleColor)
                .minimumScaleFactor(0.5)

            VStack(alignment: .leading) {
                        ForEach(["КНИЖНЫЙ", "МИР"], id: \.self) { line in
                            Text(line)
                                .applyNegativeSpacing(
                                    font: headerSubtitleFont,
                                    color: Constants.headerSubtitleColor,
                                    spacingType: .subtitleLines
                                )
                                .minimumScaleFactor(0.5)
                        }
                    }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var inputFields: some View {
        VStack(spacing: 0) {
            HStack {
                Text(emailTitle)
                    .font(inputFieldTitleFont)
                    .foregroundColor(Constants.inputFieldTitleColor)

                TextField("", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(inputFieldFont)
                    .foregroundColor(Constants.inputFieldTitleColor)
                    .frame(maxWidth: .infinity, minHeight: Constants.inputFieldHeight)
                    .multilineTextAlignment(.leading)

                if !email.isEmpty {
                    Button(action: {
                        email = ""
                    }, label: {
                        Constants.clearButtonImage
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .foregroundColor(Constants.inputFieldTitleColor)
                    })
                }
            }
            .padding(.horizontal, Constants.sidePadding)
            .frame(height: Constants.inputFieldContainerHeight)

            Divider()
                .background(Constants.inputFieldBorderColor)
                .padding(.leading, Constants.sidePadding)

            HStack {
                Text(passwordTitle)
                    .font(inputFieldTitleFont)
                    .foregroundColor(Constants.inputFieldTitleColor)

                if isPasswordVisible {
                    TextField("", text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .font(inputFieldFont)
                        .foregroundColor(Constants.inputFieldTitleColor)
                        .frame(maxWidth: .infinity, minHeight: Constants.inputFieldHeight)
                        .multilineTextAlignment(.leading)
                } else {
                    SecureField("", text: $password)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                        .font(inputFieldFont)
                        .foregroundColor(Constants.inputFieldTitleColor)
                        .frame(maxWidth: .infinity, minHeight: Constants.inputFieldHeight)
                        .multilineTextAlignment(.leading)
                }

                if !password.isEmpty {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }, label: {
                        (isPasswordVisible ? Constants.hidePasswordImage : Constants.showPasswordImage)
                            .resizable()
                            .frame(width: Constants.iconSize, height: Constants.iconSize)
                            .foregroundColor(Constants.inputFieldTitleColor)
                    })
                }
            }
            .padding(.horizontal, Constants.sidePadding)
            .frame(height: Constants.inputFieldContainerHeight)
        }
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.inputFieldCornerRadius)
                .stroke(Constants.inputFieldBorderColor, lineWidth: 1)
        )
    }

    var signInButton: some View {
        Button(action: {
            router.navigateTo(.mainTab)
        }, label: {
            Text(signInButtonTitle)
                .font(buttonFont)
                .foregroundColor(!email.isEmpty && !password.isEmpty ? Constants.buttonActiveTextColor : Constants.buttonInactiveTextColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(!email.isEmpty && !password.isEmpty ? Constants.buttonActiveColor : Constants.buttonInactiveColor)
                .cornerRadius(Constants.buttonCornerRadius)
                .animation(.easeInOut(duration: 0.2), value: !email.isEmpty && !password.isEmpty)
        })
        .disabled(email.isEmpty || password.isEmpty)
        .frame(maxWidth: .infinity, minHeight: Constants.buttonHeight)
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

        // MARK: - Carousel
        static let elementWidth: CGFloat = 172
        static let elementHeight: CGFloat = 270
        static let elementCornerRadius: CGFloat = 4
        static let elementSpacing: CGFloat = 8
        static let scrollSpeed: TimeInterval = 30

        // MARK: - Header

        static let headerTitleColor = AppColors.accentLight
        static let headerSubtitleColor = AppColors.secondary

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

        // MARK: - Button

        static let buttonActiveColor = AppColors.white
        static let buttonInactiveColor = AppColors.accentMedium
        static let buttonActiveTextColor = AppColors.accentDark
        static let buttonInactiveTextColor = AppColors.accentLight
    }
}
