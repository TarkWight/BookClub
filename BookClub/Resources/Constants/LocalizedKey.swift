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
    static let noveltyCarouselLabel = NSLocalizedString("noveltyCarouselLabel", comment: "Title for the novelty carousel")
    static let popularGridLabel = NSLocalizedString("popularGridLabel", comment: "Title for the popular grid")

    // MARK: - Book Details Screen
    static let readButtonTitle = NSLocalizedString("readButtonTitle", comment: "Title for the read button")
    static let addToBookmarkButtonTitle = NSLocalizedString("addToBookmarkButtonTitle", comment: "Title for the add to bookmark button")
    static let progressBarLabel = NSLocalizedString("progressBarLabel", comment: "Label for the progress bar")
    static let listOfContentsLabel = NSLocalizedString("listOfContentsLabel", comment: "Label for the list of contents")

    // MARK: - Reader Screen
    static let readerSettingsLabel = NSLocalizedString("settingsLabel", comment: "Title for the settings")
    static let readerFontSizeLabel = NSLocalizedString("fontSizeLabel", comment: "Title for the font size")
    static let readerStringSpacingLabel = NSLocalizedString("stringSpacingLabel", comment: "Title for the string spacing")
    static let readerPTLabel = NSLocalizedString("ptLabel", comment: "Title for the pt")

    // MARK: - Chapters Screen
    static let chaptersLabel = NSLocalizedString("chaptersLabel", comment: "Title for the chapters screen")

    // MARK: - Search Screen
    static let searchFieldPlaceholder = NSLocalizedString("seatchFieldPlaceholder", comment: "Placeholder for the search field")
    static let recentRequestsLabel = NSLocalizedString("recentRequestsLabel", comment: "Title for the recent requests")
    static let genresLabel = NSLocalizedString("genresLabel", comment: "Title for the genres")
    static let authorsLabel = NSLocalizedString("authorsLabel", comment: "Title for the authors")

    // MARK: - Bookmarks Screen
    static let bookmarksLabel = NSLocalizedString("bookmarksLabel", comment: "Title for the bookmarks screen")
    static let favoritesLabel = NSLocalizedString("favoritesLabel", comment: "Title for the favorites")
    static let readingNowLabel = NSLocalizedString("readingNowLabel", comment: "Title for the reading now")
    static let quotesLabel = NSLocalizedString("quotesLabel", comment: "Title for the quotes")

    // MARK: - Navigation
    static let backButtonTitle = NSLocalizedString("backButtonTitle", comment: "Title for the back button")
}
