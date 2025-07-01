//
//  MockNetworkService.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//
import Foundation
import Alamofire

@testable import BookClub

final class MockNetworkService: NetworkClientProtocol {
    /// If true, any request throws a URLError(.badServerResponse)
    var shouldThrowOnRequest = false
    /// The raw data to return for any successful request
    var stubbedData: Data?

    /// Async request returning a decoded model
    func request<T: Decodable>(
        _ config: NetworkConfigProtocol,
        decoder: DataDecoder = JSONDecoder()
    ) async throws -> T {
        // Simulate network failure
        if shouldThrowOnRequest {
            throw URLError(.badServerResponse)
        }
        // Ensure we have stubbed data
        guard let data = stubbedData else {
            throw DecodingError.valueNotFound(
                T.self,
                .init(codingPath: [], debugDescription: "No stubbed data")
            )
        }
        // Decode into the expected model type T
        return try decoder.decode(T.self, from: data)
    }

    /// Async request expecting no response body
    func request(_ config: NetworkConfigProtocol) async throws {
        if shouldThrowOnRequest {
            throw URLError(.badServerResponse)
        }
        // otherwise succeed silently
    }
}
