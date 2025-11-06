import Foundation
import UIKit

class DeviceIdentifier {
    static let shared = DeviceIdentifier()
    private let key = "com.rankbait.deviceId"
    
    private init() {}
    
    var deviceId: String {
        if let existingId = UserDefaults.standard.string(forKey: key) {
            return existingId
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
}
