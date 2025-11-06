import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let postsCollection = "posts"
    
    private init() {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        db.settings = settings
    }
    
    // MARK: - Create
    func addPost(_ post: Post) async throws {
        let docRef = db.collection(postsCollection).document()
        
        let postData: [String: Any] = [
            "id": post.id.uuidString,
            "friendName": post.friendName,
            "content": post.content,
            "upvotes": post.upvotes,
            "downvotes": post.downvotes,
            "createdAt": Timestamp(date: post.createdAt),
            "userVote": post.userVote as Any
        ]
        
        try await docRef.setData(postData)
    }
    
    // MARK: - Read
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await db.collection(postsCollection)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Post.self)
        }
    }
    
    // MARK: - Update
    func updatePost(_ post: Post) async throws {
        guard let docId = post.documentId else {
            print("Error: Post has no documentId")
            return
        }
        
        let postData: [String: Any] = [
            "upvotes": post.upvotes,
            "downvotes": post.downvotes,
            "userVote": post.userVote as Any
        ]
        
        try await db.collection(postsCollection).document(docId).updateData(postData)
    }
    
    // MARK: - Delete
    func deletePost(_ post: Post) async throws {
        guard let docId = post.documentId else {
            print("Error: Post has no documentId")
            return
        }
        try await db.collection(postsCollection).document(docId).delete()
    }
    
    // MARK: - Real-time Listener
    func listenToPosts(completion: @escaping ([Post]) -> Void) -> ListenerRegistration {
        return db.collection(postsCollection)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                let posts = documents.compactMap { document -> Post? in
                    try? document.data(as: Post.self)
                }
                
                DispatchQueue.main.async {
                    completion(posts)
                }
            }
    }
}
