import Foundation
import FirebaseFirestore

class GroupManager {
    static let shared = GroupManager()
    private let db = Firestore.firestore()
    private let groupsCollection = "groups"
    
    private init() {}
    
    // MARK: - Create Group
    func createGroup(name: String) async throws -> Group {
        let group = Group(name: name)
        
        let groupData: [String: Any] = [
            "id": group.id,
            "name": group.name,
            "createdAt": Timestamp(date: group.createdAt),
            "inviteCode": group.inviteCode
        ]
        
        try await db.collection(groupsCollection).document(group.id).setData(groupData)
        return group
    }
    
    // MARK: - Fetch Group by Invite Code
    func fetchGroup(byInviteCode inviteCode: String) async throws -> Group? {
        let snapshot = try await db.collection(groupsCollection)
            .whereField("inviteCode", isEqualTo: inviteCode.uppercased())
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.first.flatMap { try? $0.data(as: Group.self) }
    }
    
    // MARK: - Fetch Group by ID
    func fetchGroup(byId groupId: String) async throws -> Group? {
        let snapshot = try await db.collection(groupsCollection).document(groupId).getDocument()
        return try? snapshot.data(as: Group.self)
    }
    
    // MARK: - Listen to Group
    func listenToGroup(groupId: String, completion: @escaping (Group?) -> Void) -> ListenerRegistration {
        return db.collection(groupsCollection).document(groupId)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error listening to group: \(error?.localizedDescription ?? "Unknown")")
                    completion(nil)
                    return
                }
                
                let group = try? snapshot.data(as: Group.self)
                DispatchQueue.main.async {
                    completion(group)
                }
            }
    }
}
