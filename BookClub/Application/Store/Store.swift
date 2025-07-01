//
//  Store.swift
//  BookClub
//
//  Created by Tark Wight on 07.06.2025.

import Combine
import SwiftUI

@MainActor
final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State
    private let reducer: (inout State, Action) -> Effect<Action>

    // Keep track of running tasks to allow cancellation
    private var runningTasks: [AnyHashable: Task<Void, Never>] = [:]

    init(
        initialState: State,
        reducer: @escaping (inout State, Action) -> Effect<Action>
    ) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
        // print("[Store] send action: \(action)")
        let effect = reducer(&state, action)
        handle(effect, originatingFrom: action)
    }

    private func handle(_ effect: Effect<Action>, originatingFrom action: Action? = nil) {
        switch effect {
        case .none:
            break

        case let .cancel(id):
            // print("[Store] cancel task with id: \(id)")
            runningTasks[id]?.cancel()
            runningTasks.removeValue(forKey: id)

        case let .task(id, work):
            // print("[Store] start task id: \(id), origin: \(String(describing: action))")
            runningTasks[id]?.cancel()
            let task = Task { [weak self] in
                let action = await work()
                // print("[Store] task id: \(id) completed, sending action: \(action)")
                await MainActor.run { self?.send(action) }
            }
            runningTasks[id] = task

        case let .fireAndForget(id, work):
            if let id = id {
                // print("[Store] start fireAndForget id: \(id)")
                runningTasks[id]?.cancel()
                let task = Task { await work() }
                runningTasks[id] = task
            } else {
                // print("[Store] start fireAndForget (no id)")
                Task { await work() }
            }

        case .batch(let effects):
            for eff in effects {
                handle(eff, originatingFrom: action)
            }
        }
    }

    func binding<Value>(
        get toLocal: @escaping (State) -> Value,
        send toGlobal: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding(
            get: { toLocal(self.state) },
            set: { self.send(toGlobal($0)) }
        )
    }

    func scope<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalState, LocalAction> {
        let localStore = Store<LocalState, LocalAction>(
            initialState: toLocalState(self.state),
            reducer: { _, localAction in
                self.send(toGlobalAction(localAction))
                return .none
            }
        )
        Task { @MainActor in
            for await fullState in self.$state.values {
                localStore.state = toLocalState(fullState)
            }
        }
        return localStore
    }
}
