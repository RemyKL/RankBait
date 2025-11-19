import SwiftUI
import SDWebImageSwiftUI

struct PostCardView: View {
    let post: Post
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    @State private var isPressed: Bool = false
    @State private var profileImage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    ZStack {
                            // Outer Circle/Placeholder size definition
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)

                            // Use a conditional check for the URL loading status
                            if let urlString = profileImage, let url = URL(string: urlString) {
                                WebImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44) // Correct size
                                    .clipShape(Circle())
                            } else {
                                // Fallback for when profileImage is nil or loading
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40)) // Adjusted size to fit 44x44 container
                                    .foregroundStyle(
                                        LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        NicknameView(uid: post.uid, groupId: post.groupId)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text(formatDate(post.createdAt))
                            .font(.system(.caption2, design: .default))
                            .foregroundStyle(.secondary)
                    }
                }.task {
                    do {
                        self.profileImage = try await UserService.shared.getProfilePictureUrl(forUserId: post.uid)
                    } catch {
                        print("error fetching profile picture for user")
                        self.profileImage = nil
                    }
                    
                    
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Image(systemName: post.score >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    Text("\(post.score)")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.black)
                }
                .foregroundStyle(
                    post.score >= 0
                        ? LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottom)
                )
                .padding(.horizontal, 14)
                .padding(EdgeInsets(top: 10, leading: 14, bottom: 6, trailing: 14))
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    post.score >= 0
                                        ? LinearGradient(colors: [.green.opacity(0.3), .mint.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [.red.opacity(0.3), .pink.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                        )
                )
            }
            
//            Divider()
//                .background(.ultraThinMaterial)
            
            // Content
            Text(post.content)
                .font(.system(.body, design: .default))
                .lineSpacing(2)
                .foregroundStyle(.primary)
                .lineLimit(nil)
            
            let urlString = post.imageUrl
            if let url = URL(string: urlString) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity) // Correct size
                    .cornerRadius(12)
                    .padding(.vertical, 8)
            }
            
            // Voting
            HStack(spacing: 12) {
                VoteButton(
                    icon: "arrow.up.circle.fill",
                    label: "\(post.upvotes)",
                    isUpvote: true,
                    isActive: post.currentUserVote() == "up",
                    action: onUpvote
                )

                VoteButton(
                    icon: "arrow.down.circle.fill",
                    label: "\(post.downvotes)",
                    isUpvote: false,
                    isActive: post.currentUserVote() == "down",
                    action: onDownvote
                )

                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                        .blur(radius: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.1, perform: {}, onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        })
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Vote Button Component
struct VoteButton: View {
    let icon: String
    let label: String
    let isUpvote: Bool
    let isActive: Bool
    let action: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(.body, design: .default))
                    .fontWeight(.bold)
                
                Text(label)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: isUpvote
                                ? [Color.green, Color.mint]
                                : [Color.red, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(isActive ? 1.0 : 0.5)
                    .shadow(
                        color: (isUpvote ? Color.green : Color.red).opacity(isActive ? 0.4 : 0.2),
                        radius: isActive ? 8 : 4,
                        y: 4
                    )
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
    }
}

