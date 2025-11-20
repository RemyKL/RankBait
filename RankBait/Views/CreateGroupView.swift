import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    @State private var username = ""
    @State private var isCreating = false
    @Environment(\.isDarkModeOn) private var isDarkModeOn
    let onCreate: (Group) -> Void
    
    var isValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Create Group")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Enter Group Details")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        TextField("Group Name", text: $groupName)
                            .font(.system(.body, design: .rounded))
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(14)
                            .autocorrectionDisabled()
                        
                        TextField("Your Name", text: $username)
                            .font(.system(.body, design: .rounded))
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(14)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        createGroup()
                    } label: {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text("Create")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(!isValid || isCreating)
                }
            }
        }
        .onAppear {
            if let savedUsername = UserProfileManager.shared.username {
                username = savedUsername
            }
        }
    }
    
    private func createGroup() {
        isCreating = true
        Task {
            do {
                let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
                guard let uid = UserService.shared.getuid() else {
                    print("Error getting user id")
                    return
                }
                
                UserProfileManager.shared.setUsername(trimmedUsername)
                
                
                let group = try await GroupManager.shared.createGroup(
                    name: groupName.trimmingCharacters(in: .whitespaces),
                    creatorid: uid
                )
                
                try await UserService.shared.addUsername(groupId: group.id, username: trimmedUsername, toUserWithId: uid)
                
                await MainActor.run {
                    onCreate(group)
                    dismiss()
                }
            } catch {
                print("Error creating group: \(error)")
                await MainActor.run {
                    isCreating = false
                }
            }
        }
    }
}
