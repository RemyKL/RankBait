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
            // Must run on the main thread since we are updating @Published properties
            DispatchQueue.main.async {
                self.user = user
                self.loading = false
            }
            
            if let uid = user?.uid {
                // NOTE: UserService.shared.loadUser might need to be called in a Task block
                // if it's an async function, but we'll leave it as is for now if it's not.
                UserService.shared.loadUser(uid: uid)
            }
        }
    }


    // --- UPDATED FUNCTIONS ---
    
    // 1. Updated signIn to async throws
    func signIn(email: String, password: String) async throws {
        // We propagate the throws/awaits from the lower level function.
        // The return type is typically the UID (String), but since we update 'self.user'
        // in listenToAuthChanges, we can return Void here.
        do {
            try await AuthService.shared.signIn(email: email, password: password)
        } catch {
            // Log the error and rethrow it so the calling SwiftUI view can handle it.
            print("Sign in error:", error.localizedDescription)
            throw error
        }
    }

    // 2. Updated register to async throws
    func register(email: String, password: String) async throws {
        // This function should now handle creating the user and the user document
        do {
            try await AuthService.shared.register(email: email, password: password)
        } catch {
            // Log the error and rethrow it to the calling SwiftUI view.
            print("Registration error:", error.localizedDescription)
            throw error
        }
    }

    // --- REMAINDER OF THE VIEW MODEL ---
    
    func signOut() {
        AuthService.shared.signOut()
    }
}
