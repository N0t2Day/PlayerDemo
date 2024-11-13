//
//  AppView.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeatures>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            switch viewStore.activeModule {
            case .picker:
                MediaPicker(filter: .videos, limit: 1) { files in
                    guard files.isEmpty == false else {
                        viewStore.send(.switchTo(.splash))
                        return
                    }
                    viewStore.send(.switchTo(.player(files.first!)))
                }
            case .splash:
                SplashView(store: Store(initialState: SplashFeature.State(), reducer: {
                    SplashFeature()
                }))
            case .player(let file):
                VideoPlayerView(store: Store(initialState: VideoPlayerFeature.State(asset: .init(url: file.localURL)), reducer: {
                    VideoPlayerFeature()
                }))
            }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeatures.State(), reducer: {
        AppFeatures()
    }))
}
