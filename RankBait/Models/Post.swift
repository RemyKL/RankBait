import SwiftUI

struct Post: Identifiable, Codable {
    let id: UUID
    var friendName: String
    var content: String
    var upvotes: Int
    var downvotes: Int
    var createdAt: Date
    var userVote: String? // nil, up, or down
    
    init(id: UUID = UUID(), friendName: String, content: String, upvotes: Int = 0, downvotes: Int = 0, createdAt: Date = Date(), userVote: String? = nil) {
        self.id = id
        self.friendName = friendName
        self.content = content
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.createdAt = createdAt
        self.userVote = userVote
    }
    
    var score: Int {
        upvotes - downvotes
    }
}
