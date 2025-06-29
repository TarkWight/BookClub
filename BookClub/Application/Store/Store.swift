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
        let effect = reducer(&state, action)
        handle(effect)
    }

    private func handle(_ effect: Effect<Action>) {
        switch effect {
        case .none:
            break

        case let .cancel(id):
            // cancel and remove any running task for this id
            runningTasks[id]?.cancel()
            runningTasks.removeValue(forKey: id)

        case let .task(id, work):
            // cancel existing task with same id
            runningTasks[id]?.cancel()
            // start new task
            let task = Task { [weak self] in
                let action = await work()
                await MainActor.run { self?.send(action) }
            }
            runningTasks[id] = task

        case let .fireAndForget(id, work):
            // fire and forget tasks need not be tracked if id is nil, else track
            if let id = id {
                runningTasks[id]?.cancel()
                let task = Task { await work() }
                runningTasks[id] = task
            } else {
                Task { await work() }
            }

        case .batch(let effects):
            for eff in effects {
                handle(eff)
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
