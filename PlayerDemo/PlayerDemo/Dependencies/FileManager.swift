//
//  FileManager.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation

class AKFileManager {
    static let shared = AKFileManager()
    private init() {}
    let tempDirPath = NSTemporaryDirectory()
    lazy var tempDirURL = URL(fileURLWithPath: tempDirPath, isDirectory: true)
    let manager = FileManager.default
    
    func writeToTempDir(_ data: Data, fileName name: String, fileExtension: String) throws -> URL {
        let finalName = name + ".\(fileExtension)"
        var targetURL = tempDirURL.appendingPathComponent(finalName)
        try data.write(to: targetURL)
        targetURL = targetURL.excludedFromBackUp()
        return targetURL
    }
    
    func writeToDocumentDir(_ data: Data, fileName name: String) throws -> URL {
        let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var finalPath = documentDir.appendingPathComponent(name)
        try data.write(to: finalPath)
        finalPath = finalPath.excludedFromBackUp()
        return finalPath
    }
    
    func urlForFileName(_ name: String) -> URL? {
        let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        let finalPath = documentDir?.appendingPathComponent(name)
        return finalPath
    }
    
    func removeFromDocDir(name: String) throws {
        let documentDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let finalPath = documentDir.appendingPathComponent(name).excludedFromBackUp()
        try manager.removeItem(at: finalPath)
    }
    
    func remove(at url: URL) throws {
       try manager.removeItem(at: url)
    }
    
    func removeFromTempDir(_ fileName: String, fileExtension: String) throws {
        let targetURL = tempDirURL.appendingPathComponent("\(fileName).\(fileExtension)").excludedFromBackUp()
        try manager.removeItem(at: targetURL)
    }
    
    func clearTempDir() throws {
        try manager.contentsOfDirectory(atPath: tempDirPath).forEach { file in
            try manager.removeItem(atPath: String(format: "%@%@", tempDirPath, file))
        }
    }
    
    func fileExists(at path: String) -> Bool {
        manager.fileExists(atPath: path)
    }
    /// By default second parameter is temp dirrectory url
    func copy(from fromUrl: URL, to toUrl: URL? = nil) throws -> URL {
        let newUrl: URL = toUrl ?? tempDirURL
        try manager.copyItem(at: fromUrl, to: newUrl)
        return newUrl
    }
}

extension URL {
    func excludedFromBackUp() -> Self {
        var result = self
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try result.setResourceValues(resourceValues)
        } catch { }
        return result
    }
}
