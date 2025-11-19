//
//  RegisterView.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title)
                .bold()

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Sign Up") {
                auth.register(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
