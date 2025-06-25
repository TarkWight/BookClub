//
//  RecentSearchService.swift
//  BookClub
//
//  Created by Tark Wight on 25.06.2025.
//

import Foundation

actor RecentSearchService: RecentSearchServiceProtocol {
    private let key = "recentSearchQueries"
    private let limit = 20
    private let defaults = UserDefaults.standard

    func load() async throws -> [String] {
        return defaults.stringArray(forKey: key) ?? []
    }

    func add(_ query: String) async throws {
        var array = defaults.stringArray(forKey: key) ?? []
        array.removeAll() { $0 == query }
        array.insert(query, at: 0)
        if array.count > limit {
            array.removeLast(array.count - limit)
        }
        defaults.set(array, forKey: key)
    }

    func remove(_ query: String) async throws {
        var array = defaults.stringArray(forKey: key) ?? []
        array.removeAll { $0 == query }
        defaults.set(array, forKey: key)
    }

    func removeAll() async throws {
        defaults.removeObject(forKey: key)
    }
}
