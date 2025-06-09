//
//  GlobalHeadersAdapter.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation
import Alamofire

final class GlobalHeadersAdapter: RequestAdapter {
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        request.headers.add(name: "Accept-Language", value: Locale.current.identifier)
        completion(.success(request))
    }
}
