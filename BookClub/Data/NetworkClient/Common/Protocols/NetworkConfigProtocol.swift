//
//  NetworkConfigProtocol.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Alamofire

protocol NetworkConfigProtocol {
    var path: String { get }
    var endPoint: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
}
