//
//  ReadSessionConfig.swift
//  BookClub
//
//  Created by Tark Wight on 26.06.2025.
//

import Alamofire
import Foundation

enum ReadSessionConfig: NetworkConfigProtocol {
    case getProgresses
    case getChapters(bookId: Int)
    case createProgress([String: Any])
    case updateProgress(id: String, [String: Any])

    var path: String {
        switch self {
        case .getProgresses, .createProgress:
            return "progresses/"
        case .getChapters:
            return "chapters/"
        case .updateProgress(let id, _):
            return "progresses/\(id)"
        }
    }

    var endPoint: String {
        switch self {
        case .getProgresses:
            return ""
        case .getChapters(let bookId):
            return "?filters[book][id][$eq]=\(bookId)"
        case .createProgress:
            return ""
        case .updateProgress(let id, _):
            return "\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getProgresses, .getChapters:
            return .get
        case .createProgress:
            return .post
        case .updateProgress:
            return .put
        }
    }

    var parameters: Parameters? {
        switch self {
        case .getProgresses, .getChapters:
            return nil
        case .createProgress(let body):
            return ["data": body]
        case .updateProgress(_, let body):
            return ["data": body]
        }
    }

    var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
}
