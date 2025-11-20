import SwiftUI
import Observation
import FirebaseFirestore
import Combine

@Observable
class PostViewModel {
    var posts: [Post] = []
    var showingAddPost: Bool = false
    var currentGroupId: String? = nil
    private var listener: ListenerRegistration?
    
    var isPosting = false
    init() {}
    
    deinit {
        listener?.remove()
        print("PostViewModel deinitialized, listener removed")
    }
    
    // MARK: - Start Listening to Group Posts
    func startListening(groupId: String) {
        listener?.remove()
        currentGroupId = groupId
        listener = FirebaseManager.shared.listenToGroupPosts(groupId: groupId) { [weak self] posts in
            self?.posts = posts
        }
    }
    
    // MARK: - Create Post
//    func addPost(_ post: Post) {
//        guard currentGroupId != nil else {
//            print("Error: No group selected")
//            return
//        }
//        
//        Task {
//            do {
//                try await FirebaseManager.shared.addPost(post)
//                print("Post added successfully")
//            } catch {
//                print("Error adding post: \(error.localizedDescription)")
//            }
//        }
//    }

    func createPost(
            content: String,
            selectedMemberId: String,
            userId: String,
            image: UIImage?
        ) async {
            guard let groupId = currentGroupId, !isPosting else {
                print("Error: Post Creation Already In Progress Or No Group Selected")
                return
            }
            
            isPosting = true // start loading
            
            do {
                var postImageUrl: String? = nil
                
                // generate a unique ID for the new post immediately
                let postId = UUID()
                
                // upload the image (if present)
                if let imageToUpload = image {
                    postImageUrl = try await UserService.shared.uploadPostImage(
                        imageToUpload,
                        forPostId: postId.uuidString,
                        userId: userId
                    )
                }
                
                let newPost = Post(
                    id: postId,
                    groupId: groupId,
                    uid: selectedMemberId,
                    posterid: userId,
                    imageUrl: postImageUrl ?? "",
                    content: content.trimmingCharacters(in: .whitespaces)
                )
                
                // save the post data to Firestore
                try await FirebaseManager.shared.addPost(newPost)
                print("Post Added Successfully with URL: \(postImageUrl ?? "None")")
                
            } catch {
                print("Error Adding Post: \(error.localizedDescription)")
            }
            
            isPosting = false // stop loading
        }
    
    // MARK: - Delete
    func deletePost(_ post: Post) {
        Task {
            do {
                try await FirebaseManager.shared.deletePost(post)
                print("Post Deleted Successfully")
            } catch {
                print("Error Deleting Post: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Upvote
    func upVote(_ post: Post) {
        // find the post index
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        // get current user ID
        let userId = UserService.shared.getuid() ?? ""
        
        var updatedPost = posts[index]
        let currentVote = updatedPost.votes[userId]
        
        if currentVote == nil {
            updatedPost.upvotes += 1
            updatedPost.votes[userId] = "up"
        }
        else if currentVote == "up" {
            updatedPost.upvotes -= 1
            updatedPost.votes.removeValue(forKey: userId)
        }
        else if currentVote == "down" {
            updatedPost.downvotes -= 1
            updatedPost.upvotes += 1
            updatedPost.votes[userId] = "up"
        }
        
        posts[index] = updatedPost
        
        // Sync with Firebase
        Task {
            do {
                try await FirebaseManager.shared.updatePost(updatedPost)
            } catch {
                print("Error updating vote: \(error.localizedDescription)")
                // Revert on error
                if let originalPost = try? await FirebaseManager.shared.fetchPosts().first(where: { $0.id == post.id }) {
                    if let idx = self.posts.firstIndex(where: { $0.id == post.id }) {
                        self.posts[idx] = originalPost
                    }
                }
            }
        }
    }
    
    // MARK: - Downvote
    func downVote(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        let userId = UserService.shared.getuid() ?? ""
        var updatedPost = posts[index]
        let currentVote = updatedPost.votes[userId]
        
        if currentVote == nil {
            updatedPost.downvotes += 1
            updatedPost.votes[userId] = "down"
        }
        else if currentVote == "up" {
            updatedPost.upvotes -= 1
            updatedPost.downvotes += 1
            updatedPost.votes[userId] = "down"
        }
        else if currentVote == "down" {
            updatedPost.downvotes -= 1
            updatedPost.votes.removeValue(forKey: userId)
        }
        
        posts[index] = updatedPost
        
        // Sync with Firebase
        Task {
            do {
                try await FirebaseManager.shared.updatePost(updatedPost)
            } catch {
                print("Error updating vote: \(error.localizedDescription)")
                // Revert on error
                if let originalPost = try? await FirebaseManager.shared.fetchPosts().first(where: { $0.id == post.id }) {
                    if let idx = self.posts.firstIndex(where: { $0.id == post.id }) {
                        self.posts[idx] = originalPost
                    }
                }
            }
        }
    }
}
