//
//  SessionFactory.swift
//  BookClub
//
//  Created by Tark Wight on 22.06.2025.
//

import Alamofire
import Foundation

func createSession(tokenProvider: TokenProvider) -> Session {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 60
    config.timeoutIntervalForResource = 60
    let interceptor = makeAppInterceptor(tokenProvider: tokenProvider)
    return Session(configuration: config, interceptor: interceptor)
}
