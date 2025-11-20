import Foundation
import FirebaseFirestore

class GroupManager {
    static let shared = GroupManager()
    private let db = Firestore.firestore()
    private let groupsCollection = "groups"
    
    private init() {}
    
    // MARK: - Create Group
    func createGroup(name: String, creatorid: String) async throws -> Group {
        let group = Group(name: name, members: [creatorid])
        
        let groupData: [String: Any] = [
            "id": group.id,
            "name": group.name,
            "createdAt": Timestamp(date: group.createdAt),
            "inviteCode": group.inviteCode,
            "members": group.members
        ]
        
        // create group document in Firestore
        try await db.collection(groupsCollection).document(group.id).setData(groupData)
        return group
    }
    
    // MARK: - Fetch Group by Invite Code
    func fetchGroup(byInviteCode inviteCode: String) async throws -> Group? {
        // query Firestore for group with matching invite code
        let snapshot = try await db.collection(groupsCollection)
            .whereField("inviteCode", isEqualTo: inviteCode.uppercased())
            .limit(to: 1)
            .getDocuments() // fetch documents
        
        return snapshot.documents.first.flatMap { try? $0.data(as: Group.self) } // return the first matching group
    }
    
    // MARK: - Fetch Group by ID
    func fetchGroup(byId groupId: String) async throws -> Group? {
        // fetch group document by ID
        let snapshot = try await db.collection(groupsCollection).document(groupId).getDocument()
        return try? snapshot.data(as: Group.self) // return the group if it exists
    }
    
    // MARK: - Listen to Group
    func listenToGroup(groupId: String, completion: @escaping (Group?) -> Void) -> ListenerRegistration {
        // set up a live listener for real-time updates to the group document
        // ListenerRegistration allows stopping the listener when no longer needed
        return db.collection(groupsCollection).document(groupId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error Listening to Group: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }
                
                let group = try? snapshot.data(as: Group.self) // parse the group data

                // update on main thread
                DispatchQueue.main.async {
                    completion(group)
                }
            }
    }
    
    // MARK: - Add Member to Group
    func addMemberToGroup(groupId: String, uid: String) async throws {
        // fetch the group document
        let groupRef = db.collection(groupsCollection).document(groupId)
        
        // get current group data
        let snapshot = try await groupRef.getDocument()

        // parse group data
        guard var group = try? snapshot.data(as: Group.self) else {
            throw NSError(domain: "GroupManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not Found"])
        }
        
        // add member if not already present
        if !group.members.contains(uid) {
            group.members.append(uid)
            try await groupRef.updateData(["members": group.members])
        }
    }
    
    // MARK: - Remove Member from Group
    func removeMemberFromGroup(groupId: String, username: String) async throws {
        // fetch the group document
        let groupRef = db.collection(groupsCollection).document(groupId)
        
        // get current group data
        let snapshot = try await groupRef.getDocument()

        // parse group data
        guard var group = try? snapshot.data(as: Group.self) else {
            throw NSError(domain: "GroupManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not Found"])
        }
        
        // remove member if present
        group.members.removeAll { $0 == username }
        try await groupRef.updateData(["members": group.members])
    }
    
    // MARK: - Get Members Array
    func getMembers(for groupId: String) async throws -> [String] {
        // fetch the group document
        let snapshot = try await db.collection(groupsCollection).document(groupId).getDocument()

        // parse group data
        guard let group = try? snapshot.data(as: Group.self) else {
            return []
        }
        return group.members.sorted()
    }
    
    func getMembersWithNicknames(for groupId: String) async throws -> [String : String] {
        // fetch member IDs
        let memberIds = try await getMembers(for: groupId)

        // fetch nicknames from UserService using member IDs
        return try await UserService.shared.getNicknames(forUserIds: memberIds, inGroup: groupId)
    }

}
