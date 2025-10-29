import SwiftUI

struct PostCardView: View {
    let post: Post
    let onUpvote: () -> Void
    let onDownvote: () -> Void
    @State private var isPressed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Header: Name and Date
                VStack(alignment: .leading, spacing: 6) {
                    Text(post.friendName)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(formatDate(post.createdAt))
                        .font(.system(.caption2, design: .default))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Score
                HStack(spacing: 6) {
                    Image(systemName: post.score >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                        .font(.caption2)
                        .fontWeight(.bold)
                    
                    Text("\(post.score)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                }
                .foregroundStyle(post.score >= 0 ? .green : .red)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(post.score >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
            }
            
            Divider().opacity(0.2)
            
            // Content
            Text(post.content)
                .font(.system(.body, design: .default))
                .lineSpacing(1.5)
                .foregroundStyle(.primary)
                .lineLimit(nil)
            
            // Voting
            HStack(spacing: 10) {
                VoteButton(
                    icon: "arrow.up.circle.fill",
                    label: "\(post.upvotes)",
                    isUpvote: true,
                    isActive: post.userVote == "up",
                    action: onUpvote
                )
                
                VoteButton(
                    icon: "arrow.down.circle.fill",
                    label: "\(post.downvotes)",
                    isUpvote: false,
                    isActive: post.userVote == "down",
                    action: onDownvote
                )
                
                Spacer()
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x:0, y: 4)
        )
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0.1, perform: {}, onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
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
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(.body, design: .default))
                    .fontWeight(.semibold)
                
                Text(label)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isUpvote ? Color.green : Color.red)
                    .opacity(isActive ? 1.0 : 0.5)
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
    }
}
