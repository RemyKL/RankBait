//
//  AuthGate.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import SwiftUI

struct AuthGate: View {
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        if auth.loading {
            ProgressView()
        } else if auth.user == nil {
            LoginView().preferredColorScheme(.light)
        } else {
            GroupSelectionView()   // your real app (tab bar, home screen, etc.)
        }
    }
}

#Preview {
    AuthGate()
}
