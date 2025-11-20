import SwiftUI

struct GroupSelectionView: View {
    @State private var selectedGroup: Group?
    @State private var showingCreateGroup = false
    @State private var showingJoinGroup = false
    @State private var errorMessage: String?
    @Environment(\.isDarkModeOn) private var isDarkModeOn
    
    var body: some View {
        ZStack {
            if isDarkModeOn {
                // MARK: - Dark Mode Gradient
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ],
                    // Darker, subtler colors
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.15),
                        Color(red: 0.08, green: 0.12, blue: 0.15),
                        Color(red: 0.15, green: 0.1, blue: 0.12),
                        Color(red: 0.09, green: 0.08, blue: 0.15),
                        Color(red: 0.08, green: 0.12, blue: 0.15),
                        Color(red: 0.12, green: 0.11, blue: 0.14),
                        Color(red: 0.14, green: 0.09, blue: 0.13),
                        Color(red: 0.09, green: 0.12, blue: 0.15),
                        Color(red: 0.11, green: 0.1, blue: 0.14)
                    ]
                )
                .ignoresSafeArea()
            } else {
                // MARK: - Light Mode Gradient (Your original colors)
                MeshGradient(
                    width: 3, height: 3,
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
            }
            
            if let group = selectedGroup {
                ContentView(currentGroup: $selectedGroup)
            } else {
                groupSelectionContent
            }
        }
        .onAppear {
            loadSelectedGroup()
        }
    }
    
    private var groupSelectionContent: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                
                VStack(spacing: 12) {
                    Text("Welcome to RankBait")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("Create or Join a Group to Get Started")
                        .font(.system(.subheadline))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Button {
                        showingCreateGroup = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New Group")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                    }
                    
                    Button {
                        showingJoinGroup = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus.fill")
                            Text("Join with Invite Code")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .foregroundStyle(.primary)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.blue, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                Spacer()
                Spacer()
            }
            .navigationTitle("Select Group")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView { group in
                    selectGroup(group)
                }
            }
            .sheet(isPresented: $showingJoinGroup) {
                JoinGroupView { group in
                    selectGroup(group)
                }
            }
        }
    }
    
    private func loadSelectedGroup() {
//        if let groupId = UserGroupsManager.shared.selectedGroupId {
//            Task {
//                if let group = try? await GroupManager.shared.fetchGroup(byId: groupId) {
//                    await MainActor.run {
//                        selectedGroup = group
//                    }
//                }
//            }
//        }
        Task {
            let userId = UserService.shared.getuid() ?? ""
                do {
                    // 1. Get all remaining groups
                    let remainingGroups = try await UserService.shared.getGroups(forUserId: userId)
                    
                    // 2. Determine the next selected group
                    if let firstGroup = remainingGroups.first {
                        // Select the first remaining group
                        selectedGroup = firstGroup
                    } else {
                        // User is in no groups, set to blank
                        selectedGroup = nil
                    }
                } catch {
                    print("Failed to update selected group after leaving: \(error)")
                    // On error, perhaps default to nil to force group selection screen
                    selectedGroup = nil
                }
        }
    }
    
    private func selectGroup(_ group: Group) {
        UserGroupsManager.shared.setSelectedGroup(group.id)
        selectedGroup = group
    }
}
