import Foundation
import FirebaseFirestore

struct Group: Identifiable, Codable {
    // properties of a Group
    @DocumentID var documentId: String?
    let id: String
    var name: String
    var createdAt: Date
    var inviteCode: String
    var members: [String]
    
    init(id: String = UUID().uuidString, name: String, createdAt: Date = Date(), inviteCode: String = "", members: [String] = []) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.inviteCode = inviteCode.isEmpty ? Group.generateInviteCode() : inviteCode
        self.members = members
    }
    
    static func generateInviteCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    enum CodingKeys: String, CodingKey {
        case documentId // encode documentId as the wrapped value not the wrapper
        case id
        case name
        case createdAt
        case inviteCode
        case members
    }
}
