//
//  StrapiResponse.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

struct StrapiResponse<Data: Codable>: Codable {
    let data: Data
    let meta: PaginationMeta
}

struct PaginationMeta: Codable {
    struct Pagination: Codable {
        let page: Int
        let pageSize: Int
        let pageCount: Int
        let total: Int
    }

    let pagination: Pagination

}

struct ChapterNetworkItem: Codable {
  let id: Int64
  let documentId: String
  let title: String
  let order: Int
  let text: String
}
