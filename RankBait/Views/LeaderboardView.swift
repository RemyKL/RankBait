import SwiftUI

enum LeaderboardFilter: String, CaseIterable, Identifiable {
    case netScore = "Net Score"
    case mostUpvotes = "Upvotes"
    case mostDownvotes = "Downvotes"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .netScore: return "equal.circle.fill"
        case .mostUpvotes: return "arrow.up.circle.fill"
        case .mostDownvotes: return "arrow.down.circle.fill"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .netScore:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
        case .mostUpvotes:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        case .mostDownvotes:
            return LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct LeaderboardView: View {
    let posts: [Post]
    @State private var selectedFilter: LeaderboardFilter = .netScore
    
    private var leaderboardData: [(name: String, value: Int)] {
        let grouped = Dictionary(grouping: posts, by: { $0.friendName })
        
        let mapped = grouped.map { (name, posts) -> (name: String, value: Int) in
            let value: Int
            switch selectedFilter {
                case .netScore:
                    value = posts.reduce(0) { $0 + $1.score }
                case .mostUpvotes:
                    value = posts.reduce(0) { $0 + $1.upvotes }
                case .mostDownvotes:
                    value = posts.reduce(0) { $0 + $1.downvotes }
            }
            return (name: name, value: value)
        }
        
        switch selectedFilter {
            case .netScore:
                return mapped.sorted { $0.value < $1.value }
            case .mostUpvotes:
                return mapped.sorted { $0.value > $1.value }
            case .mostDownvotes:
                return mapped.sorted { $0.value > $1.value }
        }
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
                
                VStack(spacing: 0) {
                    filterSelector
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    if leaderboardData.isEmpty {
                        emptyStateView
                    } else {
                        leaderboardListView
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var filterSelector: some View {
        HStack(spacing: 8) {
            ForEach(LeaderboardFilter.allCases) { filter in
                FilterButton(
                    filter: filter,
                    isSelected: selectedFilter == filter,
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                )
            }
        }
        .padding(.vertical, 8)
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
                
                Text("Create Posts to See Who's Leading")
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
                        value: entry.value,
                        filter: selectedFilter
                    )
                    .padding(.horizontal, 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct FilterButton: View {
    let filter: LeaderboardFilter
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text(filter.rawValue)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(isSelected ? .bold : .semibold)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? filter.gradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? .clear : .secondary.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct LeaderboardRowView: View {
    let rank: Int
    let name: String
    let value: Int
    let filter: LeaderboardFilter
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
    
    private var valueGradient: LinearGradient {
        switch filter {
            case .netScore:
                return value >= 0
                    ? LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
                    : LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
            case .mostUpvotes:
                return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
            case .mostDownvotes:
                return LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private var valueIcon: String {
        switch filter {
            case .netScore:
                return value >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
            case .mostUpvotes:
                return "arrow.up.circle.fill"
            case .mostDownvotes:
                return "arrow.down.circle.fill"
        }
    }
    
    private var valueLabel: String {
        switch filter {
            case .netScore:
                return "net score"
            case .mostUpvotes:
                return "upvotes"
            case .mostDownvotes:
                return "downvotes"
        }
    }
    
    private var displayValue: String {
        if filter == .netScore && value >= 0 {
            return "+\(value)"
        }
        return "\(value)"
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
                    Image(systemName: valueIcon)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(displayValue)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.black)
                }
                .foregroundStyle(valueGradient)
                
                Text(valueLabel)
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
                                valueGradient.opacity(0.3),
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
