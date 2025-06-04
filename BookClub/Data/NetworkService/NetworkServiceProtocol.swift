//
//  NetworkServiceProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request(
        with config: NetworkConfig
    ) async throws -> Data

    func request<Model: Decodable>(
        with config: NetworkConfig
    ) async throws -> Model

    func encode<Value: Encodable>(_ value: Value) throws -> Data
}
