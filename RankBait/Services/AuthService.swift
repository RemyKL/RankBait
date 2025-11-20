import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private init() {}

    func signIn(email: String, password: String) async throws -> String {
        // calls Firebase Auth API to sign in
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let uid = result.user.uid
        return uid
    }

    func register(email: String, password: String) async throws -> String {
        // create the user with Firebase Auth
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let uid = result.user.uid
        
        // create the user document in Firestore
        try await UserService.shared.createUserDocument(uid: uid, email: email)
        
        return uid
    }

    func signOut() {
        try? Auth.auth().signOut()
    }
}
