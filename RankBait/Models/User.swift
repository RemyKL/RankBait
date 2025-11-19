//
//  User.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?       // uid
    var email: String?
    var profileImageUrl: String?
    var createdAt: Date?
    
    // nickname depends on group
    var nicknames: [String: String]   // key: groupId, value: nickname
    
    
    init(id: String? = nil,
         email: String? = nil,
         profileImageUrl: String? = nil,
         createdAt: Date? = Date(),
         nicknames: [String: String] = [:]) {
        
        self.id = id
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
        self.nicknames = nicknames
    }
}
