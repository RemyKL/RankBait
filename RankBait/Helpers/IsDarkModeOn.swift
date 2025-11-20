import Foundation
import SwiftUI

// define a custom EnvironmentKey for dark mode status
private struct IsDarkModeOnKey: EnvironmentKey {
    static let defaultValue: Bool = false // default value
}

// extend EnvironmentValues to use the key with a simple property name
extension EnvironmentValues {
    var isDarkModeOn: Bool {
        get { self[IsDarkModeOnKey.self] }
        set { self[IsDarkModeOnKey.self] = newValue }
    }
}
