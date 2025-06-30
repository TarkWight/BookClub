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
        let urlString = Constants.baseUrl + config.path + config.endPoint
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }
        print(
            "[NetworkClient] Requesting: \(config.method.rawValue) \(url.absoluteString)"
        )

        let encoding: ParameterEncoding =
            config.method == .get
            ? URLEncoding.default
            : JSONEncoding.default

        let data: Data
        do {
            data = try await session.request(
                url,
                method: config.method,
                parameters: config.parameters,
                encoding: encoding,
                headers: config.headers
            )
            .validate()
            .serializingData()
            .value
        } catch let afError as AFError {
            print(
                "[NetworkClient] AFError for \(url.absoluteString): \(afError)"
            )
            throw mapAFError(afError)
        }

        if let text = String(data: data, encoding: .utf8) {
            print(
                "[NetworkClient] Response from \(url.absoluteString):\n\(text)"
            )
        } else {
            print(
                "[NetworkClient] Response from \(url.absoluteString): <binary data> (\(data.count) bytes)"
            )
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print(
                "[NetworkClient] Decoding error from \(url.absoluteString): \(error)"
            )
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    func request(_ config: NetworkConfigProtocol) async throws {
        let urlString = Constants.baseUrl + config.path + config.endPoint
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }
        print(
            "[NetworkClient] Requesting (void): \(config.method.rawValue) \(url.absoluteString)"
        )

        let encoding: ParameterEncoding =
            config.method == .get
            ? URLEncoding.default
            : JSONEncoding.default

        do {
            _ = try await session.request(
                url,
                method: config.method,
                parameters: config.parameters,
                encoding: encoding,
                headers: config.headers
            )
            .validate()
            .serializingData()
            .value

            print(
                "[NetworkClient] Void response from \(url.absoluteString) succeeded"
            )
        } catch let afError as AFError {
            print(
                "[NetworkClient] AFError (void) for \(url.absoluteString): \(afError)"
            )
            throw mapAFError(afError)
        }
    }

    // MARK: — Преобразуем AFError в наш NetworkError
    private func mapAFError(_ error: AFError) -> NetworkError {
        if let urlErr = error.underlyingError as? URLError {
            switch urlErr.code {
            case .notConnectedToInternet:
                return .notConnectedToInternet
            case .timedOut:
                return .timedOut
            case .networkConnectionLost:
                return .networkConnectionLost
            default:
                return .otherURL(urlErr)
            }
        }

        if let status = error.responseCode,
            !(200...299).contains(status) {
            return .unacceptableStatusCode(status)
        }

        return .afError(error)
    }
}
