//
//  PHAuthorizationStatus+Ext.swift
//  PlayerDemo
//
//  Created by Artem Kedrov on 10.11.2024.
//

import Foundation
import PhotosUI

extension PHAuthorizationStatus {
    var message: String {
        switch self {
        case .authorized, .limited: return "Authorized"
        case .denied: return "Permissions: Denied"
        case .notDetermined: return "Permissions: Not Determined"
        case .restricted: return "Permissions: Restricted"
        @unknown default: return "Unknown"
        }
    }
}
