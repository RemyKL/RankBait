import SwiftUI
import Observation
import FirebaseFirestore

@Observable
class PostViewModel {
    var posts: [Post] = []
    var showingAddPost: Bool = false
    private var listener: ListenerRegistration?
    
    init() {
        startListening()
    }
    
    deinit {
        listener?.remove()
        print("PostViewModel deinitialized, listener removed")
    }
    
    // MARK: - Real-time Listener
    private func startListening() {
        listener = FirebaseManager.shared.listenToPosts { [weak self] posts in
            self?.posts = posts
        }
    }
    
    // MARK: - Create
    func addPost(_ post: Post) {
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
        
        var updatedPost = posts[index]
        
        if updatedPost.userVote == nil {
            updatedPost.upvotes += 1
            updatedPost.userVote = "up"
        }
        else if updatedPost.userVote == "up" {
            updatedPost.upvotes -= 1
            updatedPost.userVote = nil
        }
        else if updatedPost.userVote == "down" {
            updatedPost.downvotes -= 1
            updatedPost.upvotes += 1
            updatedPost.userVote = "up"
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
        
        var updatedPost = posts[index]
        
        if updatedPost.userVote == nil {
            updatedPost.downvotes += 1
            updatedPost.userVote = "down"
        }
        else if updatedPost.userVote == "up" {
            updatedPost.upvotes -= 1
            updatedPost.downvotes += 1
            updatedPost.userVote = "down"
        }
        else if updatedPost.userVote == "down" {
            updatedPost.downvotes -= 1
            updatedPost.userVote = nil
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
