import Foundation
import UIKit

// Generates a unique, persistent identifier for the device
// Survives app reinstallations by storing in UserDefaults
// UserDefaults is a simple key-value persistent storage system
class DeviceIdentifier {
    static let shared = DeviceIdentifier()
    private let key = "com.rankbait.deviceId"
    
    private init() {}
    
    var deviceId: String {
        // READ from UserDefaults
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }
        
        // generate new UUID and store in UserDefaults
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key) // WRITE to UserDefaults
        return newId
    }
}
