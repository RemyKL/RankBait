import SwiftUI

struct ContentView: View {
    @State private var viewModel = PostViewModel()
    let currentGroup: Group
    
    var body: some View {
        TabView {
            Tab("Posts", systemImage: "bubble.left.and.bubble.right.fill") {
                postsTabContent
            }
            
            Tab("Leaderboard", systemImage: "chart.bar.fill") {
                LeaderboardView(posts: viewModel.posts)
            }
        }
        .onAppear {
            viewModel.startListening(groupId: currentGroup.id)
        }
    }
    
    private var postsTabContent: some View {
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
                
                if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    postsListView
                }
            }
            .navigationTitle(currentGroup.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddPost = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 40, height: 40)
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddPost) {
                AddPostView(currentGroupId: currentGroup.id) { post in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        viewModel.addPost(post)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bubble.left.and.bubble.right")
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
                Text("No Posts Yet")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Tap the + button to create your first post")
                    .font(.system(.subheadline, design: .default))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.top, 80)
    }
    
    private var postsListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        onUpvote: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.upVote(post)
                            }
                        },
                        onDownvote: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.downVote(post)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.deletePost(post)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    ContentView(currentGroup: Group(name: "Preview Group"))
}
