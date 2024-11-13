//
//  SplashFeature.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation
import ComposableArchitecture
import PhotosUI

@Reducer
struct SplashFeature: SettingsPresentable {
    static let TimerDelay = 4.0
    
    @ObservableState
    struct State: Equatable {
        let startDelay: TimeInterval = TimerDelay
        var isTimerRunning: Bool = false
        var isLoading: Bool = false
        var delayCount: TimeInterval = .zero
        var photoLivraryStatus: PHAuthorizationStatus?
        @Presents var alert: AlertState<Action.PermissionAlert>?
    }
    
    enum Action: Equatable {
        case start
        case toggleTimer
        case timerTick
        case validateCount
        case permissionsCheck
        case alert(PresentationAction<PermissionAlert>)

        @CasePathable
        enum PermissionAlert: Equatable {
            case openSettings
        }
    }
    
    enum CancelID { case timer }
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                state.isLoading = false
                PlayerDemoApp.store.send(.switchTo(.picker))
                return .send(.toggleTimer)
            case .toggleTimer:
                return toggleTimer(&state)
            case .timerTick:
                state.delayCount += 1
                return .send(.validateCount)
            case .validateCount:
                guard state.startDelay == state.delayCount else {
                    return .none
                }
                return .send(.permissionsCheck)
            case .permissionsCheck:
                let status = PHPhotoLibrary.authorizationStatus()
                state.photoLivraryStatus = status
                switch status {
                case .notDetermined:
                    return .run { send in
                        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                        if status == .authorized {
                            await send(.start)
                        } else {
                            await send(.permissionsCheck)
                        }
                    }
                case .restricted, .denied:
                    state.alert = .init(title: {
                        TextState("Error")
                    }, actions: {
                        ButtonState(role: .destructive, action: .openSettings) {
                            TextState("Open Settings")
                        }
                    }, message: {
                        TextState(status.message)
                    })
                    return .none
                case .authorized, .limited:
                    return .send(.start)
                @unknown default:
                    print("Unknown authorization status.")
                }
                return .none
            case .alert(.presented(.openSettings)):
                openAppSettings()
            case .alert: return .none

            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    func toggleTimer(_ state: inout State) -> Effect<Action> {
        state.isTimerRunning.toggle()
        state.isLoading.toggle()
        if state.isTimerRunning == true {
            return .run { send in
                for await _ in self.clock.timer(interval: .seconds(1)) {
                    await send(.timerTick)
                }
            }.cancellable(id: CancelID.timer)
        } else {
            state.delayCount = .zero
            return .cancel(id: CancelID.timer)
        }
    }
}

