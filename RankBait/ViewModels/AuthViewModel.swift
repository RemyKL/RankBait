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
            // runs on the main thread since we are updating @Published properties
            DispatchQueue.main.async {
                self.user = user
                self.loading = false
            }
            
            if let uid = user?.uid {
                UserService.shared.loadUser(uid: uid)
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            try await AuthService.shared.signIn(email: email, password: password)
        } catch {
            print("Sign In Error:", error.localizedDescription)
            throw error
        }
    }

    func register(email: String, password: String) async throws {
        do {
            try await AuthService.shared.register(email: email, password: password)
        } catch {
            print("Registration Error:", error.localizedDescription)
            throw error
        }
    }
    
    func signOut() {
        AuthService.shared.signOut()
    }
}
