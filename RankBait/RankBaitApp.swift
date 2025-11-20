import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        try? Auth.auth().signOut()
        return true
    }
}

@main
struct RankBaitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // The @State wrapper correctly establishes AppSettings.shared as the source of truth.
    @AppStorage("isDarkModeOn") private var isDarkModeOn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            AuthGate()
                .preferredColorScheme(isDarkModeOn ? .dark : .light)
                .environment(\.isDarkModeOn, isDarkModeOn)
        }
    }
}
