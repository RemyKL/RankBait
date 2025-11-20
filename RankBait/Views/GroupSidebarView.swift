import SwiftUI
import FirebaseAuth

struct GroupSidebarView: View {
    @Binding var isPresented: Bool
    @Binding var selectedGroup: Group?
    @State private var userGroups: [Group] = []
    @State private var isLoading = true
    @State private var showingJoinGroup = false
    @State private var showingCreateGroup = false
    @Environment(\.isDarkModeOn) private var isDarkModeOn
    
    var body: some View {
        NavigationStack {
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
                
                if isLoading {
                    ProgressView("Loading Groups...")
                        .font(.system(.body, design: .rounded))
                } else if userGroups.isEmpty {
                    emptyStateView
                } else {
                    groupsListView
                }
            }
            .navigationTitle("My Groups")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingCreateGroup = true
                        } label: {
                            Label("Create New Group", systemImage: "plus.circle.fill")
                        }
                        
                        Button {
                            showingJoinGroup = true
                        } label: {
                            Label("Join with Code", systemImage: "person.badge.plus.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView { group in
                    addNewGroup(group)
                }
            }
            .sheet(isPresented: $showingJoinGroup) {
                JoinGroupView { group in
                    addNewGroup(group)
                }
            }
            .onAppear {
                loadUserGroups()
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 32) {
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
                Text("No Groups Yet")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                
                Text("Create or Join a Group to Get Started")
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
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
                        Text("Join with Code")
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
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 80)
    }
    
    // MARK: - Groups List View
    private var groupsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(userGroups) { group in
                    GroupRowView(
                        group: group,
                        isSelected: selectedGroup?.id == group.id,
                        onSelect: {
                            selectGroup(group)
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Load User's Groups
    private func loadUserGroups() {
        isLoading = true
        Task {
            let groups = try await UserService.shared.getGroups(forUserId: UserService.shared.getuid() ?? "")
            await MainActor.run {
                self.userGroups = groups
                isLoading = false
            }
        }
        
        
//        let groupIds = UserGroupsManager.shared.userGroupIds
//        
//        Task {
//            var groups: [Group] = []
//            
//            for groupId in groupIds {
//                if let group = try? await GroupManager.shared.fetchGroup(byId: groupId) {
//                    groups.append(group)
//                }
//            }
//            
//            await MainActor.run {
//                userGroups = groups
//                isLoading = false
//            }
//        }
    }
    
    // MARK: - Select Group
    private func selectGroup(_ group: Group) {
        UserGroupsManager.shared.setSelectedGroup(group.id)
        selectedGroup = group
        isPresented = false
    }
    
    // MARK: - Add New Group
    private func addNewGroup(_ group: Group) {
        UserGroupsManager.shared.addGroup(group.id)
        UserGroupsManager.shared.setSelectedGroup(group.id)
        selectedGroup = group
        loadUserGroups()
        isPresented = false
    }
}

// MARK: - Group Row Component
struct GroupRowView: View {
    let group: Group
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected
                                        ? LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                    lineWidth: 3
                                )
                        )
                    
                    Image(systemName: "person.3.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: isSelected ? [.blue, .cyan] : [.gray, .gray.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(isSelected ? .bold : .semibold)
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "key.fill")
                            .font(.caption2)
                        Text(group.inviteCode)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(isSelected ? 0.15 : 0.08), radius: isSelected ? 20 : 12, x: 0, y: isSelected ? 8 : 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected
                                    ? LinearGradient(
                                        colors: [.blue.opacity(0.5), .cyan.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [.white.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: 1
                            )
                            .blur(radius: 0.5)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation {
                isPressed = pressing
            }
        }, perform: {})
    }
}
