//
//  InterceptorFactory.swift
//  BookClub
//
//  Created by Tark Wight on 22.06.2025.
//

import Alamofire

func makeAppInterceptor(
    tokenProvider: TokenProvider,
    retryLimit: Int = 3
) -> Interceptor {
    let adapter = GlobalHeadersAdapter(tokenProvider: tokenProvider)
    let retrier = ServerErrorRetrier(retryLimit: retryLimit)
    return Interceptor(adapter: adapter, retrier: retrier)
}
