//
//  LocalizedKey.swift
//  BookClub
//
//  Created by Tark Wight on 29.03.2025.
//

import SwiftUI

enum LocalizedKey {
    // MARK: - Auth Screen
    static let authTitle = NSLocalizedString("loginTitle", comment: "Title of the login screen")
    static let authSubtitle = NSLocalizedString("loginSubtitle", comment: "Subtitle of the login screen")
    static let emailLabel = NSLocalizedString("emailLabel", comment: "Label for email input field")
    static let passwordLabel = NSLocalizedString("passwordLabel", comment: "Label for password input field")
    static let signInButtonTitle = NSLocalizedString("signInButtonTitle", comment: "Text for the login button")

    // MARK: - Library Screen
    static let libraryTitle = NSLocalizedString("libraryTitle", comment: "Title for the library screen")
    static let noveltyCarouselLabel = NSLocalizedString("noveltyCarouselLabel", comment: "Label for the novelty carousel")
    static let popularGridLabel = NSLocalizedString("popularGridLabel", comment: "Label for the popular grid")

    // MARK: - Book Details Screen
    static let readButtonTitle = NSLocalizedString("readButtonTitle", comment: "Title for the read button")
    static let addToBookmarkButtonTitle = NSLocalizedString("addToBookmarkButtonTitle", comment: "Title for the add to bookmark button")
    static let progressBarLabel = NSLocalizedString("progressBarLabel", comment: "Label for the progress bar")
    static let listOfContentsLabel = NSLocalizedString("listOfContentsLabel", comment: "Label for the list of contents")

    // MARK: - Reader Screen
    static let readerSettingsTitle = NSLocalizedString("settingsTitle", comment: "Title for the settings")
    static let readerFontSizeLabel = NSLocalizedString("fontSizeLabel", comment: "Label for the font size")
    static let readerStringSpacingLabel = NSLocalizedString("stringSpacingLabel", comment: "Label for the string spacing")
    static let readerPTLabel = NSLocalizedString("ptLabel", comment: "Label for the pt")

    // MARK: - Chapters Screen
    static let chaptersTitle = NSLocalizedString("chaptersTitle", comment: "Title for the chapters screen")

    // MARK: - Search Screen
    static let searchFieldPlaceholder = NSLocalizedString("searchFieldPlaceholder", comment: "Placeholder for the search field")
    static let recentRequestsLabel = NSLocalizedString("recentRequestsLabel", comment: "Title for the recent requests")
    static let genresLabel = NSLocalizedString("genresLabel", comment: "Title for the genres")
    static let authorsLabel = NSLocalizedString("authorsLabel", comment: "Title for the authors")

    // MARK: - Bookmarks Screen
    static let bookmarksTitle = NSLocalizedString("bookmarksTitle", comment: "Title for the bookmarks screen")
    static let readingNowLabel = NSLocalizedString("readingNowLabel", comment: "Label for the reading now")
    static let favoritesLabel = NSLocalizedString("favoritesLabel", comment: "Title for the favorites")
    static let quotesLabel = NSLocalizedString("quotesLabel", comment: "Title for the quotes")

    // MARK: - Navigation
    static let backButtonTitle = NSLocalizedString("backButtonTitle", comment: "Title for the back button")
}
