import SwiftUI

struct LeaderboardView: View {
    let posts: [Post]
    
    private var leaderboardData: [(name: String, downvotes: Int)] {
        let grouped = Dictionary(grouping: posts, by: { $0.friendName })
        return grouped.map { (name, posts) in
            (name: name, downvotes: posts.reduce(0) { $0 + $1.downvotes })
        }
        .sorted { $0.downvotes > $1.downvotes }
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
                        Color(red: 1.0, green: 0.92, blue: 0.95),
                        Color(red: 0.97, green: 0.94, blue: 1.0),
                        Color(red: 0.92, green: 0.95, blue: 1.0),
                        Color(red: 0.98, green: 0.92, blue: 0.98),
                        Color(red: 0.95, green: 0.98, blue: 1.0),
                        Color(red: 0.93, green: 0.96, blue: 0.99),
                        Color(red: 0.99, green: 0.94, blue: 0.96),
                        Color(red: 0.96, green: 0.98, blue: 0.99),
                        Color(red: 0.94, green: 0.96, blue: 1.0)
                    ]
                )
                .ignoresSafeArea()
                
                if leaderboardData.isEmpty {
                    emptyStateView
                } else {
                    leaderboardListView
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "trophy.fill")
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
                Text("No Rankings Yet")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Create posts to see who's leading")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.top, 80)
    }
    
    private var leaderboardListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(Array(leaderboardData.enumerated()), id: \.element.name) { index, entry in
                    LeaderboardRowView(
                        rank: index + 1,
                        name: entry.name,
                        downvotes: entry.downvotes
                    )
                    .padding(.horizontal, 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct LeaderboardRowView: View {
    let rank: Int
    let name: String
    let downvotes: Int
    @State private var isPressed: Bool = false
    
    private var rankIcon: String {
        switch rank {
        case 1: return "trophy.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "number.circle.fill"
        }
    }
    
    private var rankGradient: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.65, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2:
            return LinearGradient(
                colors: [Color(red: 0.75, green: 0.75, blue: 0.75), Color(red: 0.5, green: 0.5, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3:
            return LinearGradient(
                colors: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.4, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.gray, .gray.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                
                Image(systemName: rankIcon)
                    .font(.system(size: rank <= 3 ? 28 : 24))
                    .fontWeight(.bold)
                    .foregroundStyle(rankGradient)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Rank #\(rank)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("\(downvotes)")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.black)
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                Text("downvotes")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                LinearGradient(
                                    colors: [.red.opacity(0.3), .pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.12), radius: 15, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                        .blur(radius: 0.5)
                )
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }
    }
}
