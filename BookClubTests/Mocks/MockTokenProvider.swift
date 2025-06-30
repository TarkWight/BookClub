//
//  MockTokenProvider.swift
//  BookClub
//
//  Created by Tark Wight on 22.06.2025.
//

import Alamofire
import Foundation

@testable import BookClub

final class MockTokenProvider: TokenProvider, @unchecked Sendable {
    var token: String?
}
