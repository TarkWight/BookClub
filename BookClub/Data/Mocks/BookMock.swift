//
//  BookMock.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import Foundation

struct BookMockModel: Identifiable {
    let id = UUID.init()
    let imageName: String
    let title: String
    let author: String
}

enum BookMock {
    static let allBooks: [BookMockModel] = [
        BookMockModel(imageName: "Cover1", title: "Понедельник начинается в субботу", author: "Аркадий и Борис Стругацкие"),
        BookMockModel(imageName: "Cover2", title: "Код да Винчи", author: "Дэн Браун"),
        BookMockModel(imageName: "Cover3", title: "Преступление и наказание", author: "Фёдор Достоевский"),
        BookMockModel(imageName: "Cover4", title: "Собачье сердце", author: "Михаил Булгаков"),
        BookMockModel(imageName: "Cover5", title: "Три товарища", author: "Эрих Мария Ремарк"),
        BookMockModel(imageName: "Cover6", title: "Мастер и Маргарита", author: "Михаил Булгаков"),
        BookMockModel(imageName: "Cover7", title: "Портрет Дориана Грея", author: "Оскар Уайльд"),
        BookMockModel(imageName: "Cover8", title: "Солярис", author: "Станислав Лем"),
        BookMockModel(imageName: "Cover9", title: "1984", author: "Джордж Оруэлл"),
        BookMockModel(imageName: "Cover10", title: "Бойцовский клуб", author: "Чак Паланик"),
        BookMockModel(imageName: "Cover11", title: "Чистый код", author: "Роберт Мартин"),
        BookMockModel(imageName: "Cover12", title: "Swift: Карманный справочник", author: "Эрик Садун"),
        BookMockModel(imageName: "Cover13", title: "Рассвет жатвы", author: "Сьюзен Коллинз"),
        BookMockModel(imageName: "Cover14", title: "Swift для детей", author: "Мэри Лим"),
        BookMockModel(imageName: "Cover15", title: "Программирование на Kotlin для Android", author: "Пьер-Оливье Лоранс, Аманда Хинчман-Домингес"),
    ]

    static func getBooks(for count: Count) -> [BookMockModel] {
        switch count {
        case .three: return Array(allBooks.prefix(3))
        case .five: return Array(allBooks.prefix(5))
        case .all: return allBooks
        }
    }

    enum Count {
        case three
        case five
        case all
    }
}
