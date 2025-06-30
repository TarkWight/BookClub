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
    static let loginTitle = NSLocalizedString(
        "loginTitle",
        comment: "Title of the login screen"
    )
    static let loginSubtitle = NSLocalizedString(
        "loginSubtitle",
        comment: "Subtitle of the login screen"
    )
    static let emailTitle = NSLocalizedString(
        "emailTitle",
        comment: "Title for email input field"
    )
    static let passwordTitle = NSLocalizedString(
        "passwordTitle",
        comment: "Title for password input field"
    )
    static let signInButtonTitle = NSLocalizedString(
        "signInButtonTitle",
        comment: "Text for the login button"
    )

    // MARK: - Library Screen
    static let libraryLabel = NSLocalizedString(
        "libraryLabel",
        comment: "Title for the library screen"
    )
    static let noveltyCarouselLabel = NSLocalizedString(
        "noveltyCarouselLabel",
        comment: "Title for the novelty carousel"
    )
    static let popularGridLabel = NSLocalizedString(
        "popularGridLabel",
        comment: "Title for the popular grid"
    )

    // MARK: - Book Details Screen
    static let downloadButtonTitle = NSLocalizedString(
        "downloadButtonTitle",
        comment: "Title fot the download book button"
    )
    static let readButtonTitle = NSLocalizedString(
        "readButtonTitle",
        comment: "Title for the read button"
    )
    static let removeFromFavoritesTitle = NSLocalizedString(
        "removeFromFavoritesTitle",
        comment: "Title for the delete from favorite to bookmark button"
    )
    static let addToBookmarkButtonTitle = NSLocalizedString(
        "addToBookmarkButtonTitle",
        comment: "Title for the add favorite to bookmark button"
    )
    static let progressBarLabel = NSLocalizedString(
        "progressBarLabel",
        comment: "Label for the progress bar"
    )
    static let listOfContentsLabel = NSLocalizedString(
        "listOfContentsLabel",
        comment: "Label for the list of contents"
    )

    // MARK: - Reader Screen
    static let readerSettingsLabel = NSLocalizedString(
        "settingsLabel",
        comment: "Title for the settings"
    )
    static let readerFontSizeLabel = NSLocalizedString(
        "fontSizeLabel",
        comment: "Title for the font size"
    )
    static let readerStringSpacingLabel = NSLocalizedString(
        "stringSpacingLabel",
        comment: "Title for the string spacing"
    )
    static let readerPTLabel = NSLocalizedString(
        "ptLabel",
        comment: "Title for the pt"
    )

    // MARK: - Chapters Screen
    static let chaptersLabel = NSLocalizedString(
        "chaptersLabel",
        comment: "Title for the chapters screen"
    )

    // MARK: - Search Screen
    static let recentRequestsLabel = NSLocalizedString(
        "recentRequestsLabel",
        comment: "Title for the recent requests"
    )
    static let genresLabel = NSLocalizedString(
        "genresLabel",
        comment: "Title for the genres"
    )
    static let authorsLabel = NSLocalizedString(
        "authorsLabel",
        comment: "Title for the authors"
    )

    // MARK: - Bookmarks Screen
    static let bookmarksLabel = NSLocalizedString(
        "bookmarksLabel",
        comment: "Title for the bookmarks screen"
    )
    static let favoritesLabel = NSLocalizedString(
        "favoritesLabel",
        comment: "Title for the favorites"
    )
    static let readingNowLabel = NSLocalizedString(
        "readingNowLabel",
        comment: "Title for the reading now"
    )
    static let quotesLabel = NSLocalizedString(
        "quotesLabel",
        comment: "Title for the quotes"
    )

    // MARK: - Navigation
    static let backButtonTitle = NSLocalizedString(
        "backButtonTitle",
        comment: "Title for the back button"
    )
}

extension LocalizedKey {
    // MARK: - Placeholders
    static let authorPlaceholder = NSLocalizedString(
        "authorPlaceholder",
        comment: ""
    )

    static let bookTitlePlaceholder = NSLocalizedString(
        "bookTitlePlaceholder",
        comment: ""
    )

    static let searchFieldPlaceholder = NSLocalizedString(
        "seatchFieldPlaceholder",
        comment: "Placeholder for the search field"
    )

    static let chaptersPlaceholder = NSLocalizedString(
        "chaptersPlaceholder",
        comment: "Label for the empty list of chapters"
    )
}

extension LocalizedKey {
    // MARK: — LoginError
    static let tokenNotFound = NSLocalizedString(
        "error_tokenNotFound",
        comment: ""
    )
    static let identifierNotFound = NSLocalizedString(
        "error_identifierNotFound",
        comment: ""
    )
    static let passwordNotFound = NSLocalizedString(
        "error_passwordNotFound",
        comment: ""
    )
    static let unexpectedData = NSLocalizedString(
        "error_unexpectedData",
        comment: ""
    )
    static let unhandledError = NSLocalizedString(
        "error_unhandledError",
        comment: ""
    )
    static let invalidCredentials = NSLocalizedString(
        "error_invalidCredentials",
        comment: ""
    )
    static let networkError = NSLocalizedString("error_network", comment: "")

    // MARK: — NetworkError
    static let noNetwork = NSLocalizedString("error_noNetwork", comment: "")
    static let requestFailed = NSLocalizedString(
        "error_requestFailed",
        comment: ""
    )
    static let vpnActive = NSLocalizedString("error_vpnActive", comment: "")
    static let badStatusCode = NSLocalizedString(
        "error_badStatusCode",
        comment: ""
    )
    static let decodingError = NSLocalizedString(
        "error_decodingError",
        comment: ""
    )
    static let noData = NSLocalizedString("error_noData", comment: "")
    static let urlError = NSLocalizedString("error_urlError", comment: "")
    static let requestTimeout = NSLocalizedString(
        "error_requestTimeout",
        comment: ""
    )
    static let notCached = NSLocalizedString("error_notCached", comment: "")
}
