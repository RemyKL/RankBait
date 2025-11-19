//
//  ConfigurationManager.swift
//  RankBait
//
//  Created by Remy Laurens on 11/18/25.
//

import Foundation


struct AppConfiguration {
    static let cloudinaryCloudName: String = {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let configDict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = configDict["CloudinaryCloudName"] as? String else {
            fatalError("CloudinaryCloudName not found in Configuration.plist!")
        }
        return value
    }()
    
    // Repeat for the Upload Preset
    static let cloudinaryUploadPreset: String = {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let configDict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let value = configDict["CloudinaryUploadPreset"] as? String else {
            fatalError("CloudinaryUploadPreset not found in Configuration.plist!")
        }
        return value
    }()
}

