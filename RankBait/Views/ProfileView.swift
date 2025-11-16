//
//  ProfileView.swift
//  RankBait
//
//  Created by Remy Laurens on 11/15/25.
//

import SwiftUI

struct ProfileView: View {
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
                    ProfileInfo()
                    ProfileSettings()
                }
            }
        }
    }
}

struct ProfileInfo: View {
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "person.crop.circle.fill").font(.system(size: 128)).foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                ZStack(alignment: .bottom) {
//                    Circle()
//                        .frame(width: 32, height: 32)
//                        .fill(Color.white)
//                    Button {
//                        
//                    } label : {
//                        
//                        Circle().frame(width: 30, height: 30)
//                    }
                }
               
            }
            Text("Full Name").fontWeight(.bold).font(.title3)
            Text("smaller text").foregroundStyle(.gray).font(.caption)
            HStack {
                VStack (spacing: 5) {
                    Image(systemName: "crown.fill").foregroundStyle(Color.yellow)
                    Text("20").font(.title3).fontWeight(.bold)
                    Text("Total Votes").font(.caption).foregroundStyle(Color.gray)
                }
                VStack (spacing: 5) {
                    Image(systemName: "medal.fill").foregroundStyle(Color.gray)
                    Text("2").font(.title3).fontWeight(.bold)
                    Text("Average Rank").font(.caption).foregroundStyle(Color.gray)
                }
                VStack (spacing: 5) {
                    Image(systemName: "text.bubble.fill").foregroundStyle(Color.blue)
                    Text("5").font(.title3).fontWeight(.bold)
                    Text("Total Posts").font(.caption).foregroundStyle(Color.gray)
                }
            }.padding(15)
        }
    }
}

struct ProfileSettings : View {
    var body: some View {
        VStack (spacing: 0) {
            NavigationLink {} label: {
                ProfileSettingsRow(title: "Personal", icon: "person.fill")
            }.padding(16)
            Divider()
            NavigationLink {} label: {
                ProfileSettingsRow(title: "General", icon: "slider.horizontal.3")
            }.padding(16)
            Divider()
            NavigationLink {} label: {
                ProfileSettingsRow(title: "Notifications", icon: "bell.fill")
            }.padding(16)
            Divider()
            NavigationLink {} label: {
                ProfileSettingsRow(title: "Help", icon: "questionmark.circle.fill")
            }.padding(16)
            Divider()
        }
        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(25)
    }
}

struct ProfileSettingsRow: View {
    var title : String
    var icon : String
    var body: some View {
        HStack {
            Image(systemName: icon).font(.system(size: 18)).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)).foregroundStyle(Color(red: 0.1, green: 0.1, blue: 0.1))
            Text(title).font(.title3).foregroundStyle(Color.black)
            Spacer()
            Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(.gray.opacity(0.6))
        }
    }
}

#Preview {
    ProfileView()
}
