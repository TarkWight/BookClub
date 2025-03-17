//
//  LocalizedKey.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

@MainActor
enum LocalizedKey {
    // MARK: - Login Screen
    static let loginTitle = NSLocalizedString("loginTitle", comment: "Title of the login screen")
    static let loginSubtitle = NSLocalizedString("loginSubtitle", comment: "Subtitle of the login screen")
    static let emailTitle = NSLocalizedString("emailTitle", comment: "Title for email input field")
    static let passwordTitle = NSLocalizedString("passwordTitle", comment: "Title for password input field")
    static let signInButtonTitle = NSLocalizedString("signInButtonTitle", comment: "Text for the login button")
}
