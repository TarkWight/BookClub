//
//  Loadable.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

enum Loadable<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failure(String)
}

extension Loadable {
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
}
