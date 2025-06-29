//
//  Effect.swift
//  BookClub
//
//  Created by Tark Wight on 08.06.2025.
//

import Foundation

enum Effect<Action> {
    case none
    case cancel(id: AnyHashable)
    case task(id: AnyHashable, work: @Sendable () async -> Action)
    case fireAndForget(id: AnyHashable?, work: @Sendable () async -> Void)
    case batch([Effect<Action>])

    func map<GlobalAction>(
        _ transform: @escaping (Action) -> GlobalAction
    ) -> Effect<GlobalAction> {
        switch self {
        case .none:
            return .none

        case let .cancel(id):
            return .cancel(id: id)

        case let .task(id, work):
            return .task(id: id) {
                let action = await work()
                return transform(action)
            }

        case let .fireAndForget(id, work):
            return .fireAndForget(id: id) {
                await work()
            }

        case let .batch(effects):
            return .batch(effects.map { $0.map(transform) })
        }
    }

    static func merge(_ effects: Effect<Action>...) -> Effect<Action> {
        .batch(effects)
    }

    func cancellable(id: AnyHashable) -> Effect<Action> {
        switch self {
        case .none, .cancel:
            return self

        case let .task(_, work):
            return .task(id: id, work: work)

        case let .fireAndForget(_, work):
            return .fireAndForget(id: id, work: work)

        case let .batch(effects):
            return .batch(effects.map { $0.cancellable(id: id) })
        }
    }
}
