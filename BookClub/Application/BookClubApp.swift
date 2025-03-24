//
//  BookClubApp.swift
//  BookClub
//
//  Created by Tark Wight on 12.03.2025.
//

import SwiftUI

@main
struct BookClubApp: App {
    @StateObject private var textManager = TextChunkManager()
    
    //TODO: - Вызывается один раз, чтобы загрузить ан устройство книгу
    /// Иначе нужно закомментировать весь init
    init() {
        if let plistURL = Bundle.main.url(forResource: "LocalConfig", withExtension: "plist"),
           let data = try? Data(contentsOf: plistURL),
           let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let path = dict["BookFilePath"] as? String {
            
            let fileURL = URL(fileURLWithPath: path)
            let processor = TextProcessingService()
            
            do {
                try processor.processRawText(from: fileURL)
                print("Всё готово.")
            } catch {
                print("Ошибка при обработке текста: \(error)")
            }
        } else {
            print("LocalConfig.plist не найден или повреждён")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(textManager)
        }
    }
}
