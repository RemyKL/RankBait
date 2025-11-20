import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let postsCollection = "posts"
        
    private init() {}
    
    // MARK: - Create Post
    func addPost(_ post: Post) async throws {
        // reference to Firebase posts document
        let docRef = db.collection(postsCollection).document()
        
        let postData: [String: Any] = [
            "id": post.id.uuidString,
            "groupId": post.groupId,
            "posterid": post.posterid,
            "uid": post.uid,
            "imageUrl": post.imageUrl,
            "content": post.content,
            "upvotes": post.upvotes,
            "downvotes": post.downvotes,
            "createdAt": Timestamp(date: post.createdAt),
            "votes": post.votes
        ]
        
        // adds new post document to Firebase
        try await docRef.setData(postData)
    }
    
    // MARK: - Read All Posts
    func fetchPosts() async throws -> [Post] {
        let snapshot = try await db.collection(postsCollection)
            .order(by: "createdAt", descending: true) // orders posts by creation date, newest first
            .getDocuments()
        
        // maps documents to Post objects
        return snapshot.documents.compactMap { document in
            try? document.data(as: Post.self)
        }
    }
    
    // MARK: - Update Post
    func updatePost(_ post: Post) async throws {
        // ensures post has a valid documentId
        guard let docId = post.documentId else {
            print("Error: Post Has No documentId")
            return
        }
        
        let postData: [String: Any] = [
            "upvotes": post.upvotes,
            "downvotes": post.downvotes,
            "votes": post.votes
        ]
        
        // updates post document in Firebase
        try await db.collection(postsCollection).document(docId).updateData(postData)
    }
    
    // MARK: - Delete Post
    func deletePost(_ post: Post) async throws {
        // ensures post has a valid documentId
        guard let docId = post.documentId else {
            print("Error: Post Has No documentId")
            return
        }

        // deletes post document from Firebase
        try await db.collection(postsCollection).document(docId).delete()
    }
    
    // MARK: - Listen to Group Posts
    func listenToGroupPosts(groupId: String, completion: @escaping ([Post]) -> Void) -> ListenerRegistration {
        // builds a live query (listener) to listen for posts in a specific group
        // ListenerRegistration allows stopping the listener when no longer needed
        return db.collection(postsCollection)
            .whereField("groupId", isEqualTo: groupId) // filters posts by groupId
            .order(by: "createdAt", descending: true) // orders posts by creation date, newest first

            // sets up a snapshot listener for real-time updates
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error Fetching Documents: \(error?.localizedDescription ?? "Unknown Error")")
                    completion([])
                    return
                }
                
                // maps documents to Post objects
                let posts = documents.compactMap { document -> Post? in
                    try? document.data(as: Post.self)
                }
                
                // updates the UI on the main thread
                DispatchQueue.main.async {
                    completion(posts) // returns the updated list of posts
                }
            }
    }
}
