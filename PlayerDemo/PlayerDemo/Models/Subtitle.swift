//
//  Subtitle.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 13.11.2024.
//

import Foundation
import AVFoundation

class Subtitle: Identifiable {
    let id: String = UUID().uuidString
    var text: String?
    var timeRange: TimeRange?
}

extension Subtitle: Equatable {
    static func == (lhs: Subtitle, rhs: Subtitle) -> Bool {
        lhs.text == rhs.text && lhs.timeRange == rhs.timeRange
    }
}

extension Subtitle: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(timeRange)
    }
}
