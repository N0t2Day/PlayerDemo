//
//  AppFeature.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppFeatures {
    @ObservableState
    struct State: Equatable {
        var activeModule: Module = .splash
    }
    
    enum Action {
        case switchTo(Module)
    }
    
    enum Module: Equatable {
        case splash
        case picker
        case player(AKFile)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .switchTo(let module):
                state.activeModule = module
                return .none
            }
        }
    }
}
