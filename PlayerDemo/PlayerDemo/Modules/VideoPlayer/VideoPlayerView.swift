//
//  VideoPlayerView.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import SwiftUI
import AVFoundation
import AVKit
import ComposableArchitecture

struct VideoPlayerView: View {
    let store: StoreOf<VideoPlayerFeature>
    
    @State private var text = String()
    
    var body: some View {
        if let player = store.state.player, store.state.isReadyToPlay {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    CustomVideoPlayer(player: player, subtitle: viewStore.binding(get: \.subtitle, send: VideoPlayerFeature.Action.bindSubtitle))
                        .overlay {
                            VideoPlayerControlsView(isPlaying: viewStore.binding(get: \.isPlaying, send: .togglePlay), currentTime: viewStore.binding(get: \.currentProgress, send: VideoPlayerFeature.Action.sliderSeekTo), isEditing: viewStore.binding(get: \.isEditing, send: .toggleEditing))
                                .opacity(viewStore.controlsState.opacity)
                        }
                        .ignoresSafeArea()
                        .animation(.linear, value: viewStore.controlsState)
                        .onTapGesture {
                            viewStore.send(.toggleControls)
                        }
                    
                    infoLabel(with: viewStore)
                    
                }
                .alert("Enter label text", isPresented: viewStore.binding(get: \.textAlertVisible, send: .textAlertVisibleToggle)) {
                    TextField("Enter your name", text: $text)
                    Button("OK", action: {
                        viewStore.send(.bindText(text))
                    })
                } message: {
                    Text("This label will be shown over your video.")
                }
            }

        } else {
            ProgressView()
                .onAppear {
                    store.send(.prepare)
                }
        }
    }
    
    @ViewBuilder
    func infoLabel(with store: ViewStore<VideoPlayerFeature.State, VideoPlayerFeature.Action>) -> some View {
        
        if store.timeRange?.startTime == nil && store.timeLabelFlowActive {
            HStack {
                Text("Move the slider to specify the label start time")
                Button("Set") {
                    store.send(.setStartTime)
                }
                .padding()
            }
        } else if store.timeRange?.endTime == nil && store.timeLabelFlowActive {
            HStack {
                Text("Move the slider to specify the label end time")
                Button("Set") {
                    store.send(.setEndTime)
                }
                .padding()
            }
        } else {
            Button("Add Label") {
                store.send(.startAddLabelFlow)
            }
        }
        
    }

}
