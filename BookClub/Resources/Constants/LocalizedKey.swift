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
    
    // MARK: - Library Screen
    static let libraryLabel = NSLocalizedString("libraryLabel", comment: "Title for the library screen")
    
    
    // MARK: - Book Details Screen
    
    // MARK: - Reader Screen
    
    
    // MARK: - Chapters Screen
    static let chaptersLabel = NSLocalizedString("chaptersLabel", comment: "Title for the chapters screen")
    
    // MARK: - Search Screen
    
    // MARK: - Bookmarks Screen
    static let bookmarksLabel = NSLocalizedString("bookmarksLabel", comment: "Title for the bookmarks screen")
    
    // MARK: - Navigation
    static let backButtonTitle = NSLocalizedString("backButtonTitle", comment: "Title for the back button")
}
