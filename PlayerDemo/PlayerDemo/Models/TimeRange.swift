//
//  TimeRange.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 13.11.2024.
//

import Foundation
import AVFoundation

class TimeRange: Hashable, Equatable {
    static func == (lhs: TimeRange, rhs: TimeRange) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String = UUID().uuidString
    
    var startTime: CMTime?
    var endTime: CMTime?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
