//
//  isDarkModeOn.swift
//  RankBait
//
//  Created by Remy Laurens on 11/19/25.
//
import Foundation
import SwiftUI

private struct IsDarkModeOnKey: EnvironmentKey {
    static let defaultValue: Bool = false // Default value if not set
}

// 2. Extend EnvironmentValues to use the key with a simple property name
extension EnvironmentValues {
    var isDarkModeOn: Bool {
        get { self[IsDarkModeOnKey.self] }
        set { self[IsDarkModeOnKey.self] = newValue }
    }
}
