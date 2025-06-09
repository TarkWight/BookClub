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
        static let baseUrl = "https://brilliant-delight-92875246ff.strapiapp.com/api/"
    }

    private let session: Alamofire.Session

    init(session: Alamofire.Session) {
        self.session = session
    }

    func request(with config: NetworkConfig) async throws -> Data {
        let urlRequest: URLRequest
        do {
            urlRequest = try buildURLRequest(config: config)
        } catch {
            throw NetworkError.invalidURL(
              "\(Constants.baseUrl)\(config.path)\(config.endPoint)"
            )
        }

        let response = await session.request(urlRequest)
                               .serializingData()
                               .response

        if let afError = response.error {
            if let urlErr = afError.underlyingError as? URLError {
                switch urlErr.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    throw NetworkError.noNetwork
                case .clientCertificateRejected, .clientCertificateRequired:
                    throw NetworkError.vpnActive
                default:
                    throw NetworkError.underlying(urlErr.localizedDescription)
                }
            }
            throw NetworkError.underlying(afError.localizedDescription)
        }

        if let status = response.response?.statusCode,
           !(200...299).contains(status) {
            throw NetworkError.unacceptableStatusCode(status)
        }

        guard let data = response.data, !data.isEmpty else {
            throw NetworkError.noData
        }

        return data
    }

    func request<Model: Decodable>(with config: NetworkConfig) async throws -> Model {
        let data = try await request(with: config)
        do {
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    func encode<Value>(_ value: Value) throws -> Data where Value: Encodable {
        try JSONEncoder().encode(value)
    }

    // MARK: — Private Helpers

    private func buildURLRequest(config: NetworkConfig) throws -> URLRequest {
        let fullUrlString = Constants.baseUrl + config.path + config.endPoint
        guard let url = URL(string: fullUrlString) else {
            throw NetworkError.invalidURL(fullUrlString)
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
                throw NetworkError.underlying(error.localizedDescription)
            }
        }

        return urlRequest
    }
}
