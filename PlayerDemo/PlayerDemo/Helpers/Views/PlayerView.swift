//
//  PlayerView.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 11.11.2024.
//

import Foundation
import AVKit
import AVFoundation
import SwiftUI

class PlayerView: UIView {
    
    // Override the property to make AVPlayerLayer the view's backing layer.
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    // The associated player object.
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

struct CustomVideoPlayer: UIViewRepresentable {
    let player: AVPlayer
        
    @Binding var subtitle: Subtitle?
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player
        return view
    }
    
    private func createTextLayer(from subtitle: Subtitle) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "subtitle"
        textLayer.string = subtitle.text
        textLayer.fontSize = 60
        textLayer.foregroundColor = UIColor.red.cgColor
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        
        textLayer.position = CGPoint(x: 200, y: 200)
        textLayer.bounds = CGRect(x: 0, y: 0, width: 150, height: 100)
        return textLayer
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) {
        guard let subtitle = subtitle else {
            uiView.layer.sublayers?.removeAll(where: { $0 is CATextLayer })
            return
        }
        let textLayer = createTextLayer(from: subtitle)
        uiView.layer.addSublayer(textLayer)
    }
}

struct CustomSlider: View {
    
    @Binding var value: Double
    
    @State var lastCoordinateValue: CGFloat = 0.0
    var sliderRange: ClosedRange<Double> = 1...100
    var thumbColor: Color = .yellow
    var minTrackColor: Color = .blue
    var maxTrackColor: Color = .gray
    
    var body: some View {
        GeometryReader { gr in
            let thumbHeight = gr.size.height * 1.1
            let thumbWidth = gr.size.width * 0.03
            let radius = gr.size.height * 0.5
            let minValue = gr.size.width * 0.015
            let maxValue = (gr.size.width * 0.98) - thumbWidth
            
            let scaleFactor = (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound)
            let lower = sliderRange.lowerBound
            let sliderVal = (self.value - lower) * scaleFactor + minValue
            
            ZStack {
                Rectangle()
                    .foregroundColor(maxTrackColor)
                    .frame(width: gr.size.width, height: gr.size.height * 0.95)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    Rectangle()
                        .foregroundColor(minTrackColor)
                        .frame(width: sliderVal, height: gr.size.height * 0.95)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(thumbColor)
                        .frame(width: thumbWidth, height: thumbHeight)
                        .offset(x: sliderVal)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateValue = sliderVal
                                    }
                                    if v.translation.width > 0 {
                                        let nextCoordinateValue = min(maxValue, self.lastCoordinateValue + v.translation.width)
                                        self.value = ((nextCoordinateValue - minValue) / scaleFactor)  + lower
                                    } else {
                                        let nextCoordinateValue = max(minValue, self.lastCoordinateValue + v.translation.width)
                                        self.value = ((nextCoordinateValue - minValue) / scaleFactor) + lower
                                    }
                                }
                        )
                    Spacer()
                }
            }
        }
    }
}

struct VideoPlayerControlsView: View {
    
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var isEditing: Bool
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isPlaying.toggle()
                }
            Image(systemName: isPlaying == false ? "play.fill" : "pause.fill")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(Color.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            Slider(value: $currentTime, in: 0...1) { didChange in
                isEditing = didChange
            }
                .padding(.bottom, 32)

        }
        .padding()
    }
}
