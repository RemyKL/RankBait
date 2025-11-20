import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @StateObject private var auth = AuthViewModel()
    @Environment(\.isDarkModeOn) private var isDarkModeOn
    
    @State private var showAlert = false
    @State private var errorMessage = ""

    var body: some View {
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
                    Text("Enter a Username and Password")
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
                Task {
                    do {
                        let uid = try await auth.register(email: email, password: password)  
                        print("Registration and Document Creation Successful for UID: \(uid)")  
                    } catch {
                        errorMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            } label : {
                HStack {
                    Spacer()
                    Text("Sign Up")
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
        
        }.alert("Sign Up Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                // dismiss alert
            }
        } message: {
            // display error message
            Text(errorMessage)
        }
        .padding(30)

    }
}

#Preview {
    RegisterView()
}
