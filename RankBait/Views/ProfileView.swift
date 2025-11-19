//
//  ProfileView.swift
//  RankBait
//
//  Created by Remy Laurens on 11/15/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    
    let selectedGroupId: String
    let currentUserId: String
    init(selectedGroupId: String) {
        self.selectedGroupId = selectedGroupId
        self.currentUserId = UserService.shared.getuid() ?? ""
    }
    var body: some View {
        NavigationStack {
            ZStack {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ],
                    colors: [
                        Color(red: 0.97, green: 0.94, blue: 1.0),
                        Color(red: 0.95, green: 0.98, blue: 1.0),
                        Color(red: 0.98, green: 0.95, blue: 0.98),
                        Color(red: 0.96, green: 0.93, blue: 1.0),
                        Color(red: 0.95, green: 0.98, blue: 1.0),
                        Color(red: 0.97, green: 0.96, blue: 0.99),
                        Color(red: 0.98, green: 0.94, blue: 0.99),
                        Color(red: 0.96, green: 0.98, blue: 1.0),
                        Color(red: 0.97, green: 0.96, blue: 1.0)
                    ]
                )
                .ignoresSafeArea()
                VStack {
                    Text("Profile").font(.system(size: 32)).fontWeight(.bold).padding(20)
                    ProfileInfo(selectedGroupId: selectedGroupId, currentUserId: currentUserId)
                    ProfileSettings()
                }
            }
        }
    }
}

struct ProfileInfo: View {
    let selectedGroupId: String
    let currentUserId: String
    @StateObject private var viewModel : ProfileViewModel
    @State private var showEditProfile = false
    
    init(selectedGroupId: String, currentUserId: String) {
        self.selectedGroupId = selectedGroupId
        self.currentUserId = currentUserId
                // Initialize the ViewModel with the required parameters
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: currentUserId, groupId: selectedGroupId))
    }
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                if let urlString = viewModel.user?.profileImageUrl, let url = URL(string: urlString) {
                    WebImage(url: url) // Pass the URL to the initializer
                        .resizable()   // Correct spelling
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    // Fallback to the system placeholder if no URL is available
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 128))
                        .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.8))
                }
                
                
                    
                Button {
                    showEditProfile = true
                } label : {
                    ZStack() {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 38, height: 38)
                        Circle().fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        ).frame(width: 32, height: 32)
                        Image(systemName: "pencil").foregroundStyle(Color.white).font(.system(size: 18))
                    }
                }.offset(x: 0, y: 5)
               
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
            Text(viewModel.username).fontWeight(.bold).font(.title3).padding(2)
            Text(viewModel.user?.email ?? "idiot").foregroundStyle(.gray).font(.caption)
            HStack (spacing: 30) {
                VStack (spacing: 5) {
                    Image(systemName: "crown.fill").foregroundStyle(Color.yellow)
                    Text("\(viewModel.totalVotes)").font(.title3).fontWeight(.bold)
                    Text("Votes").font(.caption).foregroundStyle(Color.gray)
                }
                Divider().frame(width: 1, height: 60);
                VStack (spacing: 5) {
                    Image(systemName: "at").foregroundStyle(Color.gray)
                    Text("\(viewModel.numMentions)").font(.title3).fontWeight(.bold)
                    Text("Mentions").font(.caption).foregroundStyle(Color.gray)
                }
                Divider().frame(width: 1, height: 60);
                VStack (spacing: 5) {
                    Image(systemName: "text.bubble.fill").foregroundStyle(Color.blue)
                    Text("\(viewModel.numPosts)").font(.title3).fontWeight(.bold)
                    Text("Posts").font(.caption).foregroundStyle(Color.gray)
                }
            }.padding(15)
        }.onChange(of: selectedGroupId) { newGroupId in
            Task {
                await viewModel.updateGroupId(newGroupId: newGroupId)
                
            }
            
        }.task {
            await viewModel.loadUser()
        }.sheet(isPresented: $showEditProfile) {
            ProfileEditView(viewModel: viewModel)
        }
    }
}

struct ProfileSettings : View {
    @StateObject private var authViewModel = AuthViewModel()
    var body: some View {
        VStack (spacing: 0) {
            NavigationLink {Text("Coming Soon!")} label: {
                ProfileSettingsRow(title: "Group", icon: "person.fill")
            }.padding(16)
            Divider()
            NavigationLink {Text("Coming Soon!")} label: {
                ProfileSettingsRow(title: "General", icon: "slider.horizontal.3")
            }.padding(16)
            Divider()
            NavigationLink {Text("Coming Soon!")} label: {
                ProfileSettingsRow(title: "Notifications", icon: "bell.fill")
            }.padding(16)
            Divider()
            NavigationLink {Text("Coming Soon!")} label: {
                ProfileSettingsRow(title: "Help", icon: "questionmark.circle.fill")
            }.padding(16)
            Divider()
        }
        .background(Color(red: 235/255, green: 233/255, blue: 237/255))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(25)
        Button {
            authViewModel.signOut()
        } label : {
            HStack (alignment: .center) {
                Spacer()
                Text("Logout").padding(16)
                Spacer()
            }.background(Color(red: 242/255, green: 77/255, blue: 80/255)).foregroundColor(Color.white).cornerRadius(10).padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
        }
    }
}

struct ProfileSettingsRow: View {
    var title : String
    var icon : String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                .foregroundStyle(Color(red: 69/255, green: 68/255, blue: 70/255))
            Text(title).font(.default).foregroundStyle(Color(red: 69/255, green: 68/255, blue: 70/255))
            Spacer()
            Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(.gray.opacity(0.6))
        }
    }
}

//#Preview {
//    ProfileView()
//}
