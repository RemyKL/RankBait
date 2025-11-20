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
    @Environment(\.isDarkModeOn) private var isDarkModeOn

    var body: some View {
        NavigationStack {
            VStack (spacing: 20){
                VStack {
                    Image("Login")
                        .resizable()
                        .scaledToFit()
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                VStack (spacing: 5){
                    HStack {
                        Text("RankBait Login")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(isDarkModeOn ? Color.white : Color(red: 0.2, green: 0.2, blue: 0.3))
                        Spacer()
                    }
                    HStack {
                        Text("Please Sign in to continue")
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
                    auth.signIn(email: email, password: password)
                } label : {
                    HStack {
                        Spacer()
                        Text("Sign in")
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
                
                HStack {
                    Text("Don't have an Account?").font(.caption).foregroundStyle(Color.gray)
                    NavigationLink("Sign up", destination: RegisterView()).font(Font.caption.bold())
                }.padding(5)
            }.padding(20)
            
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
