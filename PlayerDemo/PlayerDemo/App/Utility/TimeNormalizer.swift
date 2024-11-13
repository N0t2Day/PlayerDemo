//
//  TimeNormalizer.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 13.11.2024.
//

import Foundation
import CoreMedia

enum TimeNormalizer {
    static func roundTime(_ time: CMTime?) -> Double {
        guard let time = time else { return .zero }
        return round(time.seconds)
    }
}
