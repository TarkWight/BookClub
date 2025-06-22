//
//  NetworkClientProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 22.06.2025.
//

import Alamofire

protocol NetworkClientProtocol {
    func request<T: Decodable>(
        _ config: NetworkConfigProtocol,
        decoder: DataDecoder
    ) async throws -> T
    func request(_ config: NetworkConfigProtocol) async throws
}
