import SwiftUI

struct JoinGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode = ""
    @State private var username = ""
    @State private var isJoining = false
    @State private var errorMessage: String?
    let onJoin: (Group) -> Void
    
    var isValid: Bool {
        !inviteCode.trimmingCharacters(in: .whitespaces).isEmpty &&
        inviteCode.count == 6 &&
        !username.trimmingCharacters(in: .whitespaces).isEmpty
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
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text("Join Group")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Enter the Invite Code and Your Name")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 16) {
                        TextField("ABC123", text: $inviteCode)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .textCase(.uppercase)
                            .autocorrectionDisabled()
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(14)
                            .onChange(of: inviteCode) { _, newValue in
                                inviteCode = String(newValue.prefix(6).uppercased())
                            }
                        
                        TextField("Your Name", text: $username)
                            .font(.system(.body, design: .rounded))
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(14)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                    }
                    .padding(.horizontal, 40)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
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
                        joinGroup()
                    } label: {
                        if isJoining {
                            ProgressView()
                        } else {
                            Text("Join")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(!isValid || isJoining)
                }
            }
        }
        .onAppear {
            if let savedUsername = UserProfileManager.shared.username {
                username = savedUsername
            }
        }
    }
    
    private func joinGroup() {
        isJoining = true
        errorMessage = nil
        
        Task {
            do {
                if let group = try await GroupManager.shared.fetchGroup(byInviteCode: inviteCode) {
                    let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
                    
                    UserProfileManager.shared.setUsername(trimmedUsername)
                    
                    try await GroupManager.shared.addMemberToGroup(
                        groupId: group.id,
                        username: trimmedUsername
                    )
                    
                    await MainActor.run {
                        onJoin(group)
                        dismiss()
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Invalid invite code"
                        isJoining = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error joining group"
                    isJoining = false
                }
            }
        }
    }
}
