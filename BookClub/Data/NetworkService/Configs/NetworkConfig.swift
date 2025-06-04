//
//  NetworkConfig.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

protocol NetworkConfig {
    var path: String { get }
    var endPoint: String { get }
    var task: HTTPTask { get }
    var method: HTTPMethod { get }
}
