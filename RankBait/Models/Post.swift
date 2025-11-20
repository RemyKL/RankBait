import SwiftUI
import FirebaseFirestore

struct Post: Identifiable, Codable {
    // properties of a Post
    @DocumentID var documentId: String?
    let id: UUID
    var groupId: String
    var uid: String
    var posterid: String
    var imageUrl: String
    var content: String
    var upvotes: Int
    var downvotes: Int
    var createdAt: Date
    var votes: [String: String]
    
    init(id: UUID = UUID(), groupId: String, uid: String, posterid: String, imageUrl: String, content: String, upvotes: Int = 0, downvotes: Int = 0, createdAt: Date = Date(), votes: [String: String] = [:]) {
        self.id = id
        self.groupId = groupId
        self.uid = uid
        self.posterid = posterid
        self.imageUrl = imageUrl
        self.content = content
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.createdAt = createdAt
        self.votes = votes
    }
    
    var score: Int {
        upvotes - downvotes
    }
    
    func currentUserVote() -> String? {
        let uid = UserService.shared.getuid() ?? ""
        return votes[uid]
    }
    
    enum CodingKeys: String, CodingKey {
        case documentId // encode documentId as the wrapped value not the wrapper
        case id
        case groupId
        case uid
        case posterid
        case imageUrl
        case content
        case upvotes
        case downvotes
        case createdAt
        case votes
    }
}
