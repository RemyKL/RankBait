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
    @Environment(\.isDarkModeOn) private var isDarkModeOn

    var body: some View {
//        VStack(spacing: 20) {
//            Text("Create Account")
//                .font(.title)
//                .bold()
//
//            TextField("Email", text: $email)
//                .textFieldStyle(.roundedBorder)
//            SecureField("Password", text: $password)
//                .textFieldStyle(.roundedBorder)
//
//            Button("Sign Up") {
//                auth.register(email: email, password: password)
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
        VStack (spacing: 20){
            VStack {
                Image("Register")
                    .resizable()
                    .scaledToFit()
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            VStack (spacing: 5){
                HStack {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(isDarkModeOn ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.3))
                    Spacer()
                }
                HStack {
                    Text("Enter a username and password")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
            }.padding(.bottom)
            
            VStack (spacing: 30) {
                TextField("Email", text: $email)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isDarkModeOn ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.9, green: 0.9, blue:0.95))
                            .frame(height: 40)
                    )
                SecureField("Password", text: $password)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isDarkModeOn ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color(red: 0.9, green: 0.9, blue:0.95))
                            .frame(height: 40)
                    )
            }
            
            Button {
                auth.register(email: email, password: password)
            } label : {
                HStack {
                    Spacer()
                    Text("Sign up")
                    Spacer()
                }
                .padding(10)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                ).foregroundColor(Color.white).cornerRadius(20)
            }
        
        }.padding(30)

    }
}

#Preview {
    RegisterView()
}
