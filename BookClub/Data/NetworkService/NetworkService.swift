//
//  NetworkService.swift
//  BookClub
//
//  Created by Tark Wight on 31.05.2025.
//

import Foundation
import Alamofire

final class NetworkService: NetworkServiceProtocol {
    private enum Constants {
        static let baseUrl = "https://react-midterm.kreosoft.space/api/"
    }

    private let session: Alamofire.Session

    init(session: Alamofire.Session) {
        self.session = session
    }

    // MARK: – Public Methods

    func request(
        with config: NetworkConfig
    ) async throws -> Data {
        let urlRequest = try buildURLRequest(config: config)
        let response = await session.request(urlRequest).serializingData().response

        if let statusCode = response.response?.statusCode,
           !(200...299).contains(statusCode) {
            throw AFError.responseValidationFailed(
                reason: .unacceptableStatusCode(code: statusCode)
            )
        }

        guard let data = response.data else {
            throw AFError.responseSerializationFailed(
                reason: .inputDataNilOrZeroLength
            )
        }

        return data
    }

    func request<Model: Decodable>(
        with config: NetworkConfig
    ) async throws -> Model {
        let data = try await request(with: config)
        do {
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            throw error
        }
    }

    func encode<Value>(_ value: Value) throws -> Data where Value: Encodable {
        try JSONEncoder().encode(value)
    }

    // MARK: – Private Helpers

    private func buildURLRequest(
        config: NetworkConfig
    ) throws -> URLRequest {
        let fullUrlString = Constants.baseUrl + config.path + config.endPoint
        guard let url = URL(string: fullUrlString) else {
            throw AFError.invalidURL(url: fullUrlString)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.method = HTTPMethod(rawValue: config.method.rawValue)
            .flatMap { Alamofire.HTTPMethod(rawValue: $0.rawValue) } ?? .get

        urlRequest.headers = HTTPHeaders([
            "Accept": "application/json",
            "Content-Type": "application/json"
        ])

        switch config.task {
        case .request:
            break

        case .requestBody(let data):
            urlRequest.httpBody = data

        case .requestUrlParameters(let params):
            do {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
            } catch {
                throw AFError.parameterEncodingFailed(
                    reason: .jsonEncodingFailed(error: error)
                )
            }
        }

        return urlRequest
    }
}
