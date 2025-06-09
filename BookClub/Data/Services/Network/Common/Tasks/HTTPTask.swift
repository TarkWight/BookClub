//
//  HTTPTask.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation

typealias Parameters = [String: Any]

enum HTTPTask {
    case request
    case requestBody(Data)
    case requestUrlParameters(Parameters)
}
