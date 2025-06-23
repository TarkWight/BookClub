//
//  SearchEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

import Foundation

struct SearchEnvironment: Sendable {
    let networkClient: NetworkClientProtocol
    let storage: BookStorageServiceProtocol
}
