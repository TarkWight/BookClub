//
//  MockNetworkService.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation
import Alamofire

@testable import BookClub

final class MockNetworkService: NetworkServiceProtocol {
    var encodedBody: Data?
    var shouldThrowOnRequest = false
    var shouldThrowOnEncode = false
    var stubbedResponse: AuthResponse?

    func request(with config: NetworkConfig) async throws -> Data {
        if shouldThrowOnRequest {
            throw URLError(.badServerResponse)
        }
        guard let stubbedResponse else {
            throw DecodingError.valueNotFound(
                AuthResponse.self,
                .init(codingPath: [],
                      debugDescription: "Stubbed response is nil")
            )
        }
        return try encode(stubbedResponse)
    }

    func request<Model>(with config: NetworkConfig) async throws -> Model where Model: Decodable {
        let data = try await request(with: config)
        return try JSONDecoder().decode(Model.self, from: data)
    }

    func encode<Value>(_ value: Value) throws -> Data where Value: Encodable {
        if shouldThrowOnEncode {
            throw EncodingError.invalidValue(value, .init(
                codingPath: [],
                debugDescription: "Stubbed encoding failure"
            ))
        }
        return try JSONEncoder().encode(value)
    }
}
