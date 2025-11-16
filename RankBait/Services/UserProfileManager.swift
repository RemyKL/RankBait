import Foundation

class UserProfileManager {
    static let shared = UserProfileManager()
    private let usernameKey = "com.rankbait.username"
    
    private init() {}
    
    // MARK: - Get Username
    var username: String? {
        return UserDefaults.standard.string(forKey: usernameKey)
    }
    
    // MARK: - Set Username
    func setUsername(_ username: String) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        UserDefaults.standard.set(trimmedUsername, forKey: usernameKey)
    }
    
    // MARK: - Check if Username Exists
    var hasUsername: Bool {
        return username != nil && !username!.isEmpty
    }
    
    // MARK: - Clear Username (for testing/logout)
    func clearUsername() {
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }
}
