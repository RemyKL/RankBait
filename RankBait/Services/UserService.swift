//
//  UserService.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import FirebaseFirestore
import FirebaseFirestore
import Combine
import FirebaseAuth
import FirebaseStorage
import Cloudinary

class UserService: ObservableObject {
    static let shared = UserService()
    
    @Published var currentUser: User? = nil
    private let db = Firestore.firestore()
    private var nicknameCache: [String: String] = [:]
    private let storage = Storage.storage()
    private let CLOUDINARY_CLOUD_NAME = AppConfiguration.cloudinaryCloudName
    private let CLOUDINARY_UPLOAD_PRESET = AppConfiguration.cloudinaryUploadPreset
    
    private init() {}
    
    func createUserDocument(uid: String, email: String) async throws {
        let newUser = User(id: uid, email: email)
        
        try? db.collection("users").document(uid).setData(from: newUser)
    }
    
    func addUsername(groupId: String, username: String, toUserWithId uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        
        // Firestore lets you update a nested dictionary key directly
        let fieldPath = "nicknames.\(groupId)"
        
        try await userRef.updateData([
            fieldPath : username
        ])
    }
    
    func leaveGroup(forGroupId groupId: String, forUserId uid: String) async throws{
        let groupRef = db.collection("groups").document(groupId)
        
        try await groupRef.updateData([
            "members": FieldValue.arrayRemove([uid])
        ])
        
        let userRef = db.collection("users").document(uid)
        let updatePath = "nicknames.\(groupId)"
            
        try await userRef.updateData([
            updatePath: FieldValue.delete() // This deletes the key-value pair
        ])
        
        
        print("successfully removed member")
    }
    
    func getGroups(forUserId uid: String) async throws -> [Group] {
        let groupsCollection = db.collection("groups")
        
        // 1. Query for groups where the 'members' array contains the user's ID
        let query = groupsCollection
            .whereField("members", arrayContains: uid)
        
        do {
            // 2. Execute the query
            let snapshot = try await query.getDocuments()
            
            // 3. Decode the documents into an array of Group objects
            let groups = snapshot.documents.compactMap { doc in
                try? doc.data(as: Group.self)
            }
            
            return groups
        } catch {
            print("Error fetching groups for user \(uid): \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func getuid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func getNicknames(forUserIds ids: [String], inGroup groupId: String) async throws -> [String : String] {
        
        var result: [String : String] = [:]
        
        for id in ids {
            let snapshot = try await db.collection("users").document(id).getDocument()
            
            if let user = try? snapshot.data(as: User.self) {
                if let nickname = user.nicknames[groupId] {
                    result[id] = nickname
                } else {
                    // fallback if nickname was never set for this group
                    result[id] = "User"
                }
            }
        }
        
        return result
    }
    
    func getNickname(forUserId uid: String, inGroup groupId: String) async throws -> String? {
        if let cachedNickname = nicknameCache[uid] {
            return cachedNickname
        }
        
        let snapshot = try await db.collection("users").document(uid).getDocument()
        
        if let user = try? snapshot.data(as: User.self), let nickname = user.nicknames[groupId] {
            nicknameCache[uid] = nickname
            return nickname
        }
        
        return nil
    }
    
    
    func loadUser(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async {
                    self.currentUser = user
                }
            }
        }
    }
    
    func fetchFullUser(forUserId uid: String) async throws -> User? {
        let snapshot = try await db.collection("users").document(uid).getDocument()
        
        return try? snapshot.data(as: User.self)
    }
    
    func countUserPosts(forUserId uid: String, forGroupId groupId: String) async throws -> Int {
        let postsCollection = db.collection("posts")
        // Query for posts where 'posterid' matches the user's UID
        let query = postsCollection.whereField("posterid", isEqualTo: uid).whereField("groupId", isEqualTo: groupId)
        
        // Use the count() aggregation function for efficiency
        let snapshot = try await query.count.getAggregation(source: .server)
        // Convert the count result to an Int
        return Int(truncating: snapshot.count)
    }
    
    func calculateTotalVotes(forUserId uid: String, forGroupId groupId: String) async throws -> Int {
        let postsCollection = db.collection("posts")
        // Query for posts where 'posterid' matches the user's UID
        let query = postsCollection.whereField("posterid", isEqualTo: uid).whereField("groupId", isEqualTo: groupId)
        
        let snapshot = try await query.getDocuments()
        
        var totalVotes = 0
        // Iterate through all matching posts and sum the count of their votes arrays
        for document in snapshot.documents {
            if let post = try? document.data(as: Post.self) {
                totalVotes += post.votes.count
            }
        }
        
        return totalVotes
    }
    
    func calculateUserMentions(forUserId uid: String, forGroupId groupId: String) async throws -> Int {
        let postsCollection = db.collection("posts")
        let query = postsCollection.whereField("uid", isEqualTo: uid).whereField("groupId", isEqualTo: groupId)
        
        let snapshot = try await query.count.getAggregation(source: .server)
        
        return Int(truncating: snapshot.count)
    }
    
    func updateNickname(userId: String, groupId: String, newNickname: String) async throws {
        let userRef = db.collection("users").document(userId)
    
        try await userRef.updateData([
                    "nicknames.\(groupId)": newNickname
        ])
        
        // Invalidate or update the local cache after a successful write
        nicknameCache[userId] = newNickname
    }
//    
//    func uploadProfileImage(_ image: UIImage, forUserId userId: String) async throws{
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            throw NSError(domain: "UserServiceErro", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])
//        }
//        
//        let storageRef = storage.reference().child("profile_pictures/\(userId).jpg")
//        
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//        
//        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
//        
//        let downloadURL = try await storageRef.downloadURL().absoluteString
//        
//        let userRef = db.collection("users").document(userId)
//        try await userRef.updateData([
//            "profileImageUrl": downloadURL
//        ])
//    }
    
    func uploadProfileImage(_ image: UIImage, forUserId userId: String) async throws {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw NSError(domain: "UserServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])
            }
            
            let uniqueImageId = UUID().uuidString
        
            // Configure Cloudinary
            let config = CLDConfiguration(cloudName: CLOUDINARY_CLOUD_NAME)
            let cloudinary = CLDCloudinary(configuration: config)

            // Use the userID as the public ID in Cloudinary, making it easy to manage/overwrite
            let params = CLDUploadRequestParams().setFolder("profile_images/\(userId)").setPublicId(uniqueImageId)
            
            // Use Swift Concurrency to wrap the callback-based Cloudinary SDK
            return try await withCheckedThrowingContinuation { continuation in
                cloudinary.createUploader().upload(
                    data: imageData,
                    uploadPreset: CLOUDINARY_UPLOAD_PRESET, // Use the unsigned preset name
                    params: params,
                    progress: nil
                ) { response, error in
                    if let error = error {
                        print("Cloudinary upload error: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    
                    guard let url = response?.secureUrl else {
                        print("Cloudinary Error: No URL returned.")
                        continuation.resume(throwing: NSError(domain: "CloudinaryError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Upload succeeded but no URL returned."]))
                        return
                    }
                    
                    // If successful, update the user document in Firestore with the URL
                    let userRef = Firestore.firestore().collection("users").document(userId)
                    userRef.updateData(["profileImageUrl": url]) { dbError in
                        if let dbError = dbError {
                            print("Firestore URL Update Error: \(dbError.localizedDescription)")
                            continuation.resume(throwing: dbError)
                        } else {
                            continuation.resume(returning: ()) // Success (returns Void)
                        }
                    }
                }
            }
        }
    
    func getProfilePictureUrl(forUserId uid: String) async throws -> String? {
        
        let snapshot = try await db.collection("users").document(uid).getDocument()
        
        if let user = try? snapshot.data(as: User.self), let profileUrl = user.profileImageUrl {
            return profileUrl
        }
        
        return nil
    }
    
    func uploadPostImage(_ image: UIImage, forPostId postId: String, userId: String) async throws -> String {
        // 1. Convert image to data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "UserServiceError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])
        }
        
        // Configure Cloudinary (as before)
        let config = CLDConfiguration(cloudName: CLOUDINARY_CLOUD_NAME)
        let cloudinary = CLDCloudinary(configuration: config)

        // 2. Set unique parameters for Post Image
        // We use the 'posts' folder, then a subfolder for the user, and the unique PostID as the publicId.
        let params = CLDUploadRequestParams()
            .setFolder("posts/\(userId)") // Group posts by user ID
            .setPublicId(postId)          // Use the Post ID as the unique file name
        
        // 3. Upload and return the URL
        return try await withCheckedThrowingContinuation { continuation in
            cloudinary.createUploader().upload(
                data: imageData,
                uploadPreset: CLOUDINARY_UPLOAD_PRESET,
                params: params,
                progress: nil
            ) { response, error in
                if let error = error {
                    print("Cloudinary upload error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                // CRITICAL: Ensure you get the URL and return it
                guard let url = response?.secureUrl else {
                    print("Cloudinary Error: No URL returned.")
                    continuation.resume(throwing: NSError(domain: "CloudinaryError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Upload succeeded but no URL returned."]))
                    return
                }
                
                // Success: Return the URL string
                continuation.resume(returning: url)
            }
        }
    }
}
