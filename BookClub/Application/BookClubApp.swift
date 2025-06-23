//
//  BookClubApp.swift
//  BookClub
//
//  Created by Tark Wight on 29.05.2025.
//

import Alamofire
import SwiftUI

@main
struct BookClubApp: App {
    let store: Store<AppState, AppAction>

    init() {
        // MARK: - Services
        let keychainService = KeychainService() as KeychainServiceProtocol
        let authService =
            AuthService(
                networkClient: BookClubApp.makePlainClient(),
                keychainService: keychainService
            ) as AuthServiceProtocol

        // MARK: - Network Client with Auth
        let networkClient =
            NetworkClient(
                session: BookClubApp.makeSession(
                    with: BookClubApp.makeAuthInterceptor(
                        authService: authService,
                        keychainService: keychainService
                    )
                )
            ) as NetworkClientProtocol

        // MARK: - Core Data Storage
        let bookStorage = BookStorageService()

        // MARK: - Environment & Store
        let environment = AppEnvironment(
            authService: authService,
            networkClient: networkClient,
            bookStorage: bookStorage
        )
        self.store = Store(
            initialState: AppState(),
            reducer: { state, action in
                appReducer(state: &state, action: action, env: environment)
            }
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }

    // MARK: - Factory Methods

    private static func makePlainClient() -> NetworkClientProtocol {
        let session = makeSession(with: nil)
        return NetworkClient(session: session)
    }

    private static func makeAuthInterceptor(
        authService: AuthServiceProtocol,
        keychainService: KeychainServiceProtocol
    ) -> Interceptor {
        let adapter = AuthAdapter(keychainService: keychainService)
        let retrier = AuthRetrier(authService: authService)
        return Interceptor(adapter: adapter, retrier: retrier)
    }

    private static func makeSession(with interceptor: RequestInterceptor?)
        -> Session
    {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true

        if let interceptor = interceptor {
            return Session(configuration: config, interceptor: interceptor)
        } else {
            return Session(configuration: config)
        }
    }
}
