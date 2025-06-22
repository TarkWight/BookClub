//
//  NetworkClient.swift
//  BookClub
//
//  Created by Tark Wight on 31.05.2025.
//

import Alamofire
import Foundation

final class NetworkClient: NetworkClientProtocol {
    private enum Constants {
        static let baseUrl =
            "https://brilliant-delight-92875246ff.strapiapp.com/api/"
    }

    private let session: Session
    init(session: Session) {
        self.session = session
    }

    func request<T: Decodable>(
        _ config: NetworkConfigProtocol,
        decoder: DataDecoder = JSONDecoder()
    ) async throws -> T {
        let urlString = Constants.baseUrl + config.path + "/" + config.endPoint
        let encoding: ParameterEncoding =
            config.method == .get ? URLEncoding.default : JSONEncoding.default

        let data: Data
        do {
            data = try await session.request(
                urlString,
                method: config.method,
                parameters: config.parameters,
                encoding: encoding,
                headers: config.headers
            )
            .validate()
            .serializingData()
            .value
        } catch let afError as AFError {
            throw mapAFError(
                afError,
                response: afError.responseCode.flatMap { code in
                    HTTPURLResponse(
                        url: URL(string: urlString)!,
                        statusCode: code,
                        httpVersion: nil,
                        headerFields: nil
                    )
                }
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    func request(_ config: NetworkConfigProtocol) async throws {
        let urlString = Constants.baseUrl + config.path + "/" + config.endPoint
        let encoding: ParameterEncoding =
            config.method == .get ? URLEncoding.default : JSONEncoding.default

        do {
            _ = try await session.request(
                urlString,
                method: config.method,
                parameters: config.parameters,
                encoding: encoding,
                headers: config.headers
            )
            .validate()
            .serializingData()
            .value
        } catch let afError as AFError {
            throw mapAFError(
                afError,
                response: afError.responseCode.flatMap { code in
                    HTTPURLResponse(
                        url: URL(string: urlString)!,
                        statusCode: code,
                        httpVersion: nil,
                        headerFields: nil
                    )
                }
            )
        }
    }

    private func mapAFError(
        _ error: AFError,
        response: HTTPURLResponse?
    ) -> NetworkError {
        if let urlErr = error.underlyingError as? URLError {
            return .urlError(urlErr)
        }
        if let status = response?.statusCode,
            !(200...299).contains(status)
        {
            return .unacceptableStatusCode(status)
        }
        return .afError(error)
    }
}
