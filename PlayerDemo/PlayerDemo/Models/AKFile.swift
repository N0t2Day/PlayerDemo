//
//  AKFile.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation

struct AKFile: Identifiable {
    let id: String
    let localURL: URL
}

extension AKFile: Equatable {
    public static func == (lhs: AKFile, rhs: AKFile) -> Bool {
        lhs.id == rhs.id
    }
}

/*
extension AKFile {
    static var mock: Self {
        .init(id: UUID().uuidString, localURL: Bundle.main.url(forResource: "new_york", withExtension: "mp4")!)
    }
}
*/
