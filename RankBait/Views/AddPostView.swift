import SwiftUI

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var friendName: String = ""
    @State private var content: String = ""
    let currentGroupId: String
    let onAdd: (Post) -> Void
    
    var isValid: Bool {
        !friendName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.blue, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("WHO")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .tracking(1.2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "person.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.blue, .cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                
                                TextField("Friend's Name", text: $friendName)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                            }
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.white.opacity(0.5), lineWidth: 1)
                                            .blur(radius: 0.5)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.bubble.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.purple, .pink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("WHAT")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .tracking(1.2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 20)
                            
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text("What did they do?")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.secondary.opacity(0.6))
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 26)
                                }
                                
                                TextEditor(text: $content)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                                    .frame(minHeight: 160)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.white.opacity(0.5), lineWidth: 1)
                                            .blur(radius: 0.5)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.body)
                                .fontWeight(.semibold)
                            
                            Text("Cancel")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .red.opacity(0.2), radius: 6, y: 3)
                        )
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let newPost = Post(
                            groupId: currentGroupId,
                            friendName: friendName.trimmingCharacters(in: .whitespaces),
                            content: content.trimmingCharacters(in: .whitespaces))
                        onAdd(newPost)
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                                .fontWeight(.semibold)
                            
                            Text("Add")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: isValid
                                            ? [Color.blue, Color.cyan]
                                            : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: isValid ? Color.blue.opacity(0.4) : Color.clear,
                                    radius: 8,
                                    y: 4
                                )
                        )
                    }
                    .disabled(!isValid)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isValid)
                }
            }
        }
    }
}
