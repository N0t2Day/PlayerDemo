//
//  PlayerDemoApp.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct PlayerDemoApp: App {
    
    static let store = Store(initialState: AppFeatures.State()) {
        AppFeatures()
        ._printChanges()
    }
    
    
    var body: some Scene {
        WindowGroup {
            AppView(store: PlayerDemoApp.store)
        }
    }
}
