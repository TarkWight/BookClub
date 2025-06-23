//
//  StrapiResponse.swift
//  BookClub
//
//  Created by Tark Wight on 23.06.2025.
//

struct StrapiResponse<T: Decodable>: Decodable {
    let data: T
}
