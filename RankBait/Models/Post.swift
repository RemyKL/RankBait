import SwiftUI
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var documentId: String?
    let id: UUID
    var groupId: String
    var friendName: String
    var content: String
    var upvotes: Int
    var downvotes: Int
    var createdAt: Date
    var votes: [String: String]
    
    init(id: UUID = UUID(), groupId: String, friendName: String, content: String, upvotes: Int = 0, downvotes: Int = 0, createdAt: Date = Date(), votes: [String: String] = [:]) {
        self.id = id
        self.groupId = groupId
        self.friendName = friendName
        self.content = content
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.createdAt = createdAt
        self.votes = votes
    }
    
    var score: Int {
        upvotes - downvotes
    }
    
    func currentDeviceVote() -> String? {
        let deviceId = DeviceIdentifier.shared.deviceId
        return votes[deviceId]
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case groupId
        case friendName
        case content
        case upvotes
        case downvotes
        case createdAt
        case votes
    }
}
