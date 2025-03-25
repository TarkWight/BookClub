//
//  ChunkLoaderError.swift
//  BookClub
//
//  Created by Tark Wight on 24.03.2025.
//

import Foundation

enum ChunkLoaderError: Error, LocalizedError {
    case chunkNotFound(Int)

    var errorDescription: String? {
        switch self {
        case .chunkNotFound(let index):
            return "Chunk with index \(index) was not found in cache."
        }
    }
}
