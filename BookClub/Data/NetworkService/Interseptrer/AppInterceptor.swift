//
//  AppInterceptor.swift
//  BookClub
//
//  Created by Tark Wight on 01.06.2025.
//

import Foundation
import Alamofire

func makeAppInterceptor(
    keychainService: KeychainServiceProtocol,
    authService: AuthServiceProtocol
) -> Interceptor {
    let adapters: [RequestAdapter] = [
        AuthAdapter(keychainService: keychainService),
        GlobalHeadersAdapter()
    ]

    let retriers: [RequestRetrier] = [
        AuthRetrier(authService: authService),
        ServerErrorRetrier()
    ]

    return Interceptor(adapters: adapters, retriers: retriers)
}
