//
//  Effect.swift
//  BookClub
//
//  Created by Tark Wight on 08.06.2025.
//

import Foundation

enum Effect<Action> {
    case none
    case task(@Sendable () async -> Action)
    case fireAndForget(@Sendable () async -> Void)

    func map<GlobalAction>(
        _ transform: @escaping (Action) -> GlobalAction
    ) -> Effect<GlobalAction> {
        switch self {
        case .none:
            return .none

        case .task(let work):
            return .task {
                let action = await work()
                return transform(action)
            }

        case .fireAndForget(let work):
            return .fireAndForget {
                await work()
            }
        }
    }
}
