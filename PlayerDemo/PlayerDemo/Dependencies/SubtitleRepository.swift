//
//  SubtitleRepository.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 13.11.2024.
//

import Foundation
import CoreMedia

class SubtitleRepository: RepositoryProtocol {
    var data: [Subtitle] = []
    typealias Element = Subtitle
    
    fileprivate static var instance: SubtitleRepository?
    
    static func shared() -> SubtitleRepository? {
        if let instance = instance {
            return instance
        }
        instance = .init()
        return instance
    }
    
    private init() {
        debugPrint("[NEW INSTANCE OF:] \(self)")
    }
}

extension SubtitleRepository {
    func subtitle(for time: CMTime) -> Subtitle? {
        let roundTime = TimeNormalizer.roundTime(time)
        let firstItem = data.first { TimeNormalizer.roundTime($0.timeRange?.startTime) <= roundTime && roundTime < TimeNormalizer.roundTime($0.timeRange?.endTime)}
        return firstItem
    }
}
