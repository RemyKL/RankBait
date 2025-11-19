//
//  LoginView.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var auth = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack (spacing: 20){
                Text("RankBait")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                Button("Sign In") {
                    auth.signIn(email: email, password: password)
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink("Create an Account", destination: RegisterView())
            }
            
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
