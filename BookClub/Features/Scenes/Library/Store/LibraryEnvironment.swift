//
//  LibraryEnvironment.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

struct LibraryEnvironment: Sendable {
    let networkClient: NetworkClientProtocol
    let storage: BookStorageServiceProtocol
}
