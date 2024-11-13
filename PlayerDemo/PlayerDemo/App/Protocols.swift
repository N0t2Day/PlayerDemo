//
//  Protocols.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation
import UIKit

protocol SettingsPresentable {
    func openAppSettings()
}

extension SettingsPresentable {
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

protocol RepositoryProtocol: AnyObject {
    associatedtype Element: Identifiable
    var data: [Element] { get set }
    func add(_ element: Element)
    func first() -> Element?
    func last() -> Element?
    func getElement(at index: Int) -> Element?
}

extension RepositoryProtocol {
    func add(_ element: Element) {
        data.append(element)
    }
    
    func first() -> Element? {
        data.first
    }
    
    func last() -> Element? {
        data.last
    }
    
    func getElement(at index: Int) -> Element? {
        guard data.count > index else { return nil }
        return data[index]
    }
}
