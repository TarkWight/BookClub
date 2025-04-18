//
//  AppRouter.swift
//  BookClub
//
//  Created by Tark Wight on 13.03.2025.
//

import SwiftUI

enum AppScreen {
    case auth
    case mainTab
    case bookDetails
    case reader
    case chapters
    case search
    case bookmarks
}

class Router: ObservableObject {
    @Published var currentScreen: AppScreen = .auth

    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }

    func logout() {
        currentScreen = .auth
    }
}
