//
//  VideoPlayerFeature.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation
import ComposableArchitecture
import AVFoundation

@Reducer
struct VideoPlayerFeature {
    
    static let HIDE_UI_DELAY: TimeInterval = 3.0
    
    @ObservableState
    struct State: Equatable {
        var isPlaying: Bool = Bool()
        var currentProgress: Double = .zero
        var isEditing: Bool = Bool()
        var player: AVPlayer?
        var asset: AVURLAsset
        var canAcceptProgress: Bool = true
        var isReadyToPlay: Bool = Bool()
        var controlsState: ControlsState = .hidden
        var timerCount: TimeInterval = .zero
        var timeLabelFlowActive: Bool = Bool()
        var subtitle: Subtitle?
        var timeRange: TimeRange?
        var textAlertVisible: Bool = Bool()
        var labelText: String?
    }
    
    enum Action {
        case toggleEditing
        case togglePlay
        case printError(Error)
        case seekTo(Double)
        case sliderSeekTo(Double)
        case prepare
        case isReadyToPlay(Bool)
        case toggleControls
        case timerTick
        case startAddLabelFlow
        case bindText(String)
        case textAlertVisibleToggle
        case setStartTime
        case setEndTime
        case saveLabel
        case bindSubtitle(Subtitle?)
    }
    
    enum ControlsState {
        case visible
        case hidden
        
        var opacity: Double {
            switch self {
            case .visible: return 1
            case .hidden: return .zero
            }
        }
    }
    
    enum CancelID { case player, timer }
    
    @Dependency(\.mediaPlayer) var player
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .prepare:
                return prepare(&state)
            case .togglePlay:
                return togglePlay(&state)
            case let .printError(error):
                print("[ERROR:] \(error.localizedDescription)")
                return .none

            case .toggleEditing:
                return toggleEditing(&state)
            case let .seekTo(time):
                guard state.canAcceptProgress else { return .none }
                state.currentProgress = time
                let subtitle = SubtitleRepository.shared()?.subtitle(for: player.player.currentTime())
                return .send(.bindSubtitle(subtitle))
            case .sliderSeekTo(time: let time):
                state.currentProgress = time
                return .none
            case .isReadyToPlay(let isReady):
                state.isReadyToPlay = isReady
                return .none
            case .toggleControls:
                return toggleTimer(&state)
            case .timerTick:
                state.timerCount += 1
                if state.timerCount == VideoPlayerFeature.HIDE_UI_DELAY {
                    return .send(.toggleControls)
                }
                return .none
            case .startAddLabelFlow:
                state.timeLabelFlowActive = true
                state.timeRange = .init()
                return .send(.togglePlay)
            case .bindText(let text):
                state.labelText = text
                return .send(.saveLabel)
            case .textAlertVisibleToggle:
                state.textAlertVisible.toggle()
                return .none
            case .setStartTime:
                state.timeRange?.startTime = player.player.currentTime()
                return .none
            case .setEndTime:
                state.timeRange?.endTime = player.player.currentTime()
                return .send(.textAlertVisibleToggle)
            case .saveLabel:
                guard let timeRange = state.timeRange else { return .none }
                state.timeLabelFlowActive = false
                let subtitle = Subtitle()
                subtitle.text = state.labelText
                subtitle.timeRange = timeRange
                state.timeRange = nil
                
                SubtitleRepository.shared()?.add(subtitle)
                return .send(.textAlertVisibleToggle)
            case .bindSubtitle(let subtitle):
                state.subtitle = subtitle
                return .none
            }
        }
    }
    
    func prepare(_ state: inout State) -> Effect<Action> {
        player.configure(with: state.asset.url)
        state.player = player.player
        return .merge(
            Effect<VideoPlayerFeature.Action>
                .publisher {
                    player.currentProgressPublisher
                        .map(Action.seekTo)
                },
            Effect<VideoPlayerFeature.Action>
                .publisher {
                    player.isReadyToPlayPublisher
                        .map(Action.isReadyToPlay)
                }
        )
    }
    
    func toggleEditing(_ state: inout State) -> Effect<Action> {
        let oldValue = state.canAcceptProgress
        state.canAcceptProgress.toggle()
        if oldValue {
            state.isPlaying = false
            player.pause()
        } else {
            state.isPlaying = true
            player.seek(to: state.currentProgress)
            player.play()
        }
        return .none
    }
    
    func togglePlay(_ state: inout State) -> Effect<Action> {
        guard state.controlsState == .visible else { return .none }
        state.isPlaying.toggle()
        if state.isPlaying == true {
            player.play()
        } else {
            player.pause()
        }
        return .none
    }
    
    func toggleTimer(_ state: inout State) -> Effect<Action> {
        switch state.controlsState {
        case .visible:
            state.controlsState = .hidden
        case .hidden:
            state.controlsState = .visible
        }
        
        if state.controlsState == .visible {
            return .run { send in
                for await _ in self.clock.timer(interval: .seconds(1)) {
                    await send(.timerTick)
                }
            }.cancellable(id: CancelID.timer)
        } else {
            state.timerCount = .zero
            return .cancel(id: CancelID.timer)
        }
    }
}
