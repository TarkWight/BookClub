//
//  BookMock.swift
//  BookClub
//
//  Created by Tark Wight on 14.03.2025.
//

import Foundation

struct Book: Identifiable {
    let id: UUID = UUID()
    let imageName: String
    let title: String
    let author: String
}

struct BookMock {
    static let allBooks: [Book] = [
        Book(imageName: "Cover1", title: "Понедельник начинается в субботу", author: "Аркадий и Борис Стругацкие"),
        Book(imageName: "Cover2", title: "Код да Винчи", author: "Дэн Браун"),
        Book(imageName: "Cover3", title: "Преступление и наказание", author: "Фёдор Достоевский"),
        Book(imageName: "Cover4", title: "Собачье сердце", author: "Михаил Булгаков"),
        Book(imageName: "Cover5", title: "Три товарища", author: "Эрих Мария Ремарк"),
        Book(imageName: "Cover6", title: "Мастер и Маргарита", author: "Михаил Булгаков"),
        Book(imageName: "Cover7", title: "Портрет Дориана Грея", author: "Оскар Уайльд"),
        Book(imageName: "Cover8", title: "Солярис", author: "Станислав Лем"),
        Book(imageName: "Cover9", title: "1984", author: "Джордж Оруэлл"),
        Book(imageName: "Cover10", title: "Бойцовский клуб", author: "Чак Паланик"),
        Book(imageName: "Cover11", title: "Чистый код", author: "Роберт Мартин"),
        Book(imageName: "Cover12", title: "Swift: Карманный справочник", author: "Эрик Садун"),
        Book(imageName: "Cover13", title: "Рассвет жатвы", author: "Сьюзен Коллинз"),
        Book(imageName: "Cover14", title: "Swift для детей", author: "Мэри Лим"),
        Book(imageName: "Cover15", title: "Программирование на Kotlin для Android", author: "Пьер-Оливье Лоранс, Аманда Хинчман-Домингес"),
    ]
    
    static func getBooks() -> [Book] {
        return allBooks
    }
}

