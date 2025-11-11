import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let postsCollection = "posts"
        
    private init() {

    }
    
    // MARK: - Create Post
    func addPost(_ post: Post) async throws {
        let docRef = db.collection(postsCollection).document()
        
        let postData: [String: Any] = [
            "id": post.id.uuidString,
            "groupId": post.groupId,
            "friendName": post.friendName,
            "content": post.content,
            "upvotes": post.upvotes,
            "downvotes": post.downvotes,
            "createdAt": Timestamp(date: post.createdAt),
            "votes": post.votes
        ]
        
        try await docRef.setData(postData)
    }
    
    // MARK: - Read All Posts
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await db.collection(postsCollection)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Post.self)
        }
    }
    
    // MARK: - Update Post
    func updatePost(_ post: Post) async throws {
        guard let docId = post.documentId else {
            print("Error: Post has no documentId")
            return
        }
        
        let postData: [String: Any] = [
            "upvotes": post.upvotes,
            "downvotes": post.downvotes,
            "votes": post.votes
        ]
        
        try await db.collection(postsCollection).document(docId).updateData(postData)
    }
    
    // MARK: - Delete Post
    func deletePost(_ post: Post) async throws {
        guard let docId = post.documentId else {
            print("Error: Post has no documentId")
            return
        }
        try await db.collection(postsCollection).document(docId).delete()
    }
    
    // MARK: - Listen to Group Posts
    func listenToGroupPosts(groupId: String, completion: @escaping ([Post]) -> Void) -> ListenerRegistration {
        return db.collection(postsCollection)
            .whereField("groupId", isEqualTo: groupId)
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
