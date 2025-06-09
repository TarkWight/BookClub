//
//  BookClubApp.swift
//  BookClub
//
//  Created by Tark Wight on 29.05.2025.
//

import SwiftUI
import Alamofire

@main
struct BookClubApp: App {
    let store: Store<AppState, AppAction>

    init() {
        let session = Session()
        let networkService: NetworkServiceProtocol = NetworkService(session: session)
        let keychainService: KeychainServiceProtocol = KeychainService()

        let authService: AuthServiceProtocol = AuthService(
            networkService: networkService,
            keychainService: keychainService
        )

        let appEnv = AppEnvironment(
            authService: authService
        )

        self.store = Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: { state, action in
                appReducer(state: &state, action: action, env: appEnv)
            }
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
