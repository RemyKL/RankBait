//
//  AuthService.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private init() {}

    func signIn(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        
        let uid = result.user.uid
        
        return uid
    }

    func register(email: String, password: String) async throws -> String {
        // 1. Register the user with Firebase Auth
        // Use 'try await' to call the asynchronous and throwing Firebase API.
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // 2. Extract the UID
        let uid = result.user.uid
        
        // 3. Create the user document (Assuming this is also an async function)
        // We use 'try await' here too, as Firestore operations are asynchronous and can throw.
        try await UserService.shared.createUserDocument(uid: uid, email: email)
        
        // 4. Return the UID on successful completion of all steps
        return uid
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
