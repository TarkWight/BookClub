//
//  BookClubApp.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

@main
struct BookClubApp: App {
    private var chunkManager = TextChunkManager()
    @StateObject private var session: ReadingSession
    /// Вызывается один раз, чтобы загрузить ан устройство книгу
    /// Иначе нужно закомментировать 'if let' и 'else'

    init() {
        let manager = TextChunkManager()
        self.chunkManager = manager
        self._session = StateObject(wrappedValue: ReadingSession(chunkManager: manager))

        if let plistURL = Bundle.main.url(forResource: "LocalConfig", withExtension: "plist"),
           let data = try? Data(contentsOf: plistURL),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let path = dict["BookFilePath"] as? String {

            let fileURL = URL(fileURLWithPath: path)
            let processor = TextProcessingService()

            do {
                try processor.processRawText(from: fileURL)
                print("It's done. The text of the book has been processed.")
            } catch {
                print("Error during text processing: \(error)")
            }
        } else {
            print("LocalConfig.plist not found or corrupted")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
