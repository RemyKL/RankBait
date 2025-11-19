//
//  AuthViewModel.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import SwiftUI
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User? = nil
    @Published var loading = true

    init() {
        listenToAuthChanges()
    }

    func listenToAuthChanges() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            self.loading = false
            
            if let uid = user?.uid {
                UserService.shared.loadUser(uid: uid)
            }
        }
    }


    func signIn(email: String, password: String) {
        AuthService.shared.signIn(email: email, password: password) { result in
            switch result {
            case .success(_): break
            case .failure(let err):
                print("Sign in error:", err.localizedDescription)
            }
        }
    }

    func register(email: String, password: String) {
        AuthService.shared.register(email: email, password: password) { result in
            switch result {
            case .success(_): break
            case .failure(let err):
                print("Registration error:", err.localizedDescription)
            }
        }
    }

    func signOut() {
        AuthService.shared.signOut()
    }
}
