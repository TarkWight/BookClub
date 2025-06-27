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
    case batch([Effect<Action>])

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

        case .batch(let effects):
            let mapped = effects.map { $0.map(transform) }
            return .batch(mapped)
        }
    }
}

extension Effect {
    static func merge(_ effects: Effect<Action>...) -> Effect<Action> {
        return .batch(effects)
    }
}
