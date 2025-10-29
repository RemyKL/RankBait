import SwiftUI
import Observation

@Observable
class PostViewModel {
    var posts: [Post] = []
    var showingAddPost: Bool = false
    
    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
    
    func deletePost(_ post: Post) {
        posts.removeAll{ $0.id == post.id }
    }
        
    func upVote(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            if posts[index].userVote == nil {
                posts[index].upvotes += 1
                posts[index].userVote = "up"
            }
            else if posts[index].userVote == "up" {
                posts[index].upvotes -= 1
                posts[index].userVote = nil
            }
            else if posts[index].userVote == "down" {
                posts[index].downvotes -= 1
                posts[index].upvotes += 1
                posts[index].userVote = "up"
            }
        }
    }
    
    func downVote(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            if posts[index].userVote == nil {
                posts[index].downvotes += 1
                posts[index].userVote = "down"
            }
            else if posts[index].userVote == "up" {
                posts[index].upvotes -= 1
                posts[index].downvotes += 1
                posts[index].userVote = "down"
            }
            else if posts[index].userVote == "down" {
                posts[index].downvotes -= 1
                posts[index].userVote = nil
            }
        }
    }
}
