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
    var current: State { state }

    private let reducer: (inout State, Action) -> Effect<Action>

    init(
        initialState: State,
        reducer: @escaping (inout State, Action) -> Effect<Action>
    ) {
        self.state = initialState
        self.reducer = reducer
    }

    func send(_ action: Action) {
        let effect = reducer(&state, action)
        switch effect {
        case .none:
            break

        case .task(let work):
            Task {
                let next = await work()
                await MainActor.run { self.send(next) }
            }

        case .fireAndForget(let work):
            Task { await work() }
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
                let newLocalState = toLocalState(fullState)
                localStore.state = newLocalState
            }
        }
        return localStore
    }
}
