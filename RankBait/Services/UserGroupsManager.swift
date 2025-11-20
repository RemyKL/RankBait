import Foundation

class UserGroupsManager {
    static let shared = UserGroupsManager()
    private let userGroupsKey = "com.rankbait.userGroups"
    private let selectedGroupKey = "com.rankbait.selectedGroup"
    private let queue = DispatchQueue(label: "com.rankbait.usergroups", attributes: .concurrent)
    
    private init() {}
    
    // MARK: - Get All User's Groups
    var userGroupIds: [String] {
        return queue.sync {
            UserDefaults.standard.stringArray(forKey: userGroupsKey) ?? []
        }
    }
    
    // MARK: - Get Selected Group ID
    var selectedGroupId: String? {
        return queue.sync {
            UserDefaults.standard.string(forKey: selectedGroupKey)
        }
    }
    
    // MARK: - Add Group to User's List
    func addGroup(_ groupId: String) {
        queue.async(flags: .barrier) {
            // array of group IDs
            var groups = UserDefaults.standard.stringArray(forKey: self.userGroupsKey) ?? []
            if !groups.contains(groupId) {
                groups.append(groupId)
                UserDefaults.standard.set(groups, forKey: self.userGroupsKey)
            }
        }
    }
    
    // MARK: - Remove Group from User's List
    func removeGroup(_ groupId: String) {
        queue.async(flags: .barrier) {
            // array of group IDs
            var groups = UserDefaults.standard.stringArray(forKey: self.userGroupsKey) ?? []
            groups.removeAll { $0 == groupId }
            UserDefaults.standard.set(groups, forKey: self.userGroupsKey)
            
            // If the removed group was the selected one, clear selection
            let selectedId = UserDefaults.standard.string(forKey: self.selectedGroupKey)
            if selectedId == groupId { 
                UserDefaults.standard.removeObject(forKey: self.selectedGroupKey)
            }
        }
    }
    
    // MARK: - Set Selected Group
    func setSelectedGroup(_ groupId: String) {
        queue.async(flags: .barrier) {
            // set the selected group ID
            UserDefaults.standard.set(groupId, forKey: self.selectedGroupKey)

            // array of group IDs
            var groups = UserDefaults.standard.stringArray(forKey: self.userGroupsKey) ?? []

            // ensure the selected group is in the user's groups list
            if !groups.contains(groupId) {
                groups.append(groupId)
                UserDefaults.standard.set(groups, forKey: self.userGroupsKey)
            }
        }
    }
    
    // MARK: - Check if User is in Group
    func isInGroup(_ groupId: String) -> Bool {
        return queue.sync {
            // array of group IDs
            let groups = UserDefaults.standard.stringArray(forKey: userGroupsKey) ?? []
            return groups.contains(groupId) // return true if groupId is in the array
        }
    }
    
    // MARK: - Get All Groups Count
    var groupCount: Int {
        return queue.sync {
            // array of group IDs
            let groups = UserDefaults.standard.stringArray(forKey: userGroupsKey) ?? []
            return groups.count
        }
    }
}
