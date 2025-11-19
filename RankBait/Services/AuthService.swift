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

    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            completion(.success(result?.user.uid ?? ""))
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                completion(.failure(err))
                return
            }
            let uid = result!.user.uid
            UserService.shared.createUserDocument(uid: uid, email: email)
            completion(.success(uid))
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
