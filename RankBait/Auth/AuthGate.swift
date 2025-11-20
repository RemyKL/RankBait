import SwiftUI

struct AuthGate: View {
    // create an instance for the lifetime of the view
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        if auth.loading {
            ProgressView() // built-in loading spinner
        } else if auth.user == nil {
            LoginView().preferredColorScheme(.light)
        } else {
            GroupSelectionView() // main app view
        }
    }
}

#Preview {
    AuthGate()
}
