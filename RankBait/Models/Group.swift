import Foundation
import FirebaseFirestore

struct Group: Identifiable, Codable {
    @DocumentID var documentId: String?
    let id: String
    var name: String
    var createdAt: Date
    var inviteCode: String
    
    init(id: String = UUID().uuidString, name: String, createdAt: Date = Date(), inviteCode: String = "") {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.inviteCode = inviteCode.isEmpty ? Group.generateInviteCode() : inviteCode
    }
    
    static func generateInviteCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt
        case inviteCode
    }
}
