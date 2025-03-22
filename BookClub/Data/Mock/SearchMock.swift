//
//  SearchMock.swift
//  BookClub
//
//  Created by Tark Wight on 16.03.2025.
//

import Foundation

struct SearchMock {
    static let recentSearches: [String] = [
        "Android",
        "iOS",
        "Дэн Браун",
        "Фантастика"
    ]
    
    static let genres: [String] = [
        "Классика", "Фэнтези",
        "Фантастика", "Детектив",
        "Триллер", "Исторический роман",
        "Любовный роман", "Приключения",
        "Поэзия", "Биография",
        "Для подростков", "Для детей"
    ]
    
    struct Author: Identifiable {
        let id = UUID()
        let name: String
        let imageName: String
    }
    
    static let authors: [Author] = [
        Author(name: "Братья Стругацкие", imageName: "plStrugatskie"),
        Author(name: "Дэн Браун", imageName: "plBrown"),
        Author(name: "Фёдор Достоевский", imageName: "plDostoevsky")
    ]
    
}
