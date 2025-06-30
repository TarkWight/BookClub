//
//  BookClubApp.swift
//  BookClub
//
//  Created by Tark Wight on 29.05.2025.
//

import Alamofire
import CoreData
import SwiftUI

@main
struct BookClubApp: App {
    let store: Store<AppState, AppAction>

    init() {
        // MARK: — Core Data
        let container = NSPersistentContainer(name: "BookClub")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        // MARK: — Сервисы хранения
        let bookStorage = BookStorageService(container: container)
        let genreStorage = GenreStorageService(container: container)
        let authorStorage = AuthorStorageService(container: container)
        let chapterStorage = ChapterStorageService(container: container)

        // MARK: — Остальные сервисы
        let keychainService = KeychainService()

        let authService =
            AuthService(
                networkClient: BookClubApp.makePlainClient(),
                keychainService: keychainService
            )

        let networkClient =
            NetworkClient(
                session: BookClubApp.makeSession(
                    with: BookClubApp.makeAuthInterceptor(
                        authService: authService,
                        keychainService: keychainService
                    )
                )
            )

        let recentSearchService = RecentSearchService()
        let highlightingService = TextHighlightingService()
        let chunkManager = TextChunkManager(chapterStorage: chapterStorage)

        let charCount = AppFonts.estimateCharCountPerChunk(
            chunkScreens: 2,
            lineSpacing: 8
        )

        let readingSession = ReadingSession(
            chapterStorage: chapterStorage,
            chunkManager: chunkManager,
            highlightingService: highlightingService,
            charCountPerChunk: charCount
        )

        let environment = AppEnvironment(
            authService: authService,
            networkClient: networkClient,
            readingSession: readingSession,
            bookStorage: bookStorage,
            chapterStorage: chapterStorage,
            genreStorage: genreStorage,
            authorStorage: authorStorage,
            recentSearchService: recentSearchService
        )
        store = Store(
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
        -> Session {
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
