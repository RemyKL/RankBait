import SwiftUI
import Observation
import FirebaseFirestore

@Observable
class PostViewModel {
    var posts: [Post] = []
    var showingAddPost: Bool = false
    var currentGroupId: String? = nil
    private var listener: ListenerRegistration?
    
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
    func addPost(_ post: Post) {
        guard currentGroupId != nil else {
            print("Error: No group selected")
            return
        }
        
        Task {
            do {
                try await FirebaseManager.shared.addPost(post)
                print("Post added successfully")
            } catch {
                print("Error adding post: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Delete
    func deletePost(_ post: Post) {
        Task {
            do {
                try await FirebaseManager.shared.deletePost(post)
                print("Post deleted successfully")
            } catch {
                print("Error deleting post: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Upvote
    func upVote(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        let deviceId = DeviceIdentifier.shared.deviceId
        var updatedPost = posts[index]
        let currentVote = updatedPost.votes[deviceId]
        
        if currentVote == nil {
            updatedPost.upvotes += 1
            updatedPost.votes[deviceId] = "up"
        }
        else if currentVote == "up" {
            updatedPost.upvotes -= 1
            updatedPost.votes.removeValue(forKey: deviceId)
        }
        else if currentVote == "down" {
            updatedPost.downvotes -= 1
            updatedPost.upvotes += 1
            updatedPost.votes[deviceId] = "up"
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
        
        let deviceId = DeviceIdentifier.shared.deviceId
        var updatedPost = posts[index]
        let currentVote = updatedPost.votes[deviceId]
        
        if currentVote == nil {
            updatedPost.downvotes += 1
            updatedPost.votes[deviceId] = "down"
        }
        else if currentVote == "up" {
            updatedPost.upvotes -= 1
            updatedPost.downvotes += 1
            updatedPost.votes[deviceId] = "down"
        }
        else if currentVote == "down" {
            updatedPost.downvotes -= 1
            updatedPost.votes.removeValue(forKey: deviceId)
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
