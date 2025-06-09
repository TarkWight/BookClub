//
//  AppState.swift
//  BookClub
//
//  Created by Tark Wight on 09.06.2025.
//

import Foundation

struct AppState: Equatable {
  var path: [AppRoute] = []
  var login: LoginState = .init()
}
