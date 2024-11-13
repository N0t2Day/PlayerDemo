//
//  MediaPlayer.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 12.11.2024.
//

import Foundation
import ComposableArchitecture
import AVKit
import AVFoundation
import Combine

class MediaPlayer {
    var player: AVPlayer!
    var currentTimePublisher: PassthroughSubject<Double, Never> = .init()
    var currentProgressPublisher: PassthroughSubject<Double, Never> = .init()
    var isReadyToPlayPublisher: PassthroughSubject<Bool, Never> = .init()
    private var playerPeriodicObserver: Any?
    private var statusObserver: Any?
    init() { }
    
    func configure(with url: URL) {
        player = AVPlayer(url: url)
        setupPeriodicObservation(for: player)
    }
    
    private func setupPeriodicObservation(for player: AVPlayer) {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        playerPeriodicObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
            guard let `self` = self else { return }
            let progress = self.calculateProgress(currentTime: time.seconds)
            self.currentProgressPublisher.send(progress)
            self.currentTimePublisher.send(time.seconds)
        }
        statusObserver = player.currentItem?.observe(\.status, options:  [.new, .old], changeHandler: {[weak self]
            (playerItem, change) in
            self?.isReadyToPlayPublisher.send(playerItem.status == .readyToPlay)
        })
    }
    
    private func calculateProgress(currentTime: Double) -> Double {
        return currentTime / duration
    }
    
    private var duration: Double {
        return player.currentItem?.duration.seconds ?? 0
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: CMTime) {
        player.seek(to: time)
    }
    
    func seek(to percentage: Double) {
        let time = convertFloatToCMTime(percentage)
        player.seek(to: time)
    }
    
    private func convertFloatToCMTime(_ percentage: Double) -> CMTime {
        return CMTime(seconds: duration * percentage, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }
}

enum MediaPlayerKey: DependencyKey {
    static var liveValue: MediaPlayer = .init()
}

extension DependencyValues {
    var mediaPlayer: MediaPlayer {
        get { self[MediaPlayerKey.self] }
        set { self[MediaPlayerKey.self] = newValue }
    }
}
