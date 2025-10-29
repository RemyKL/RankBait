import SwiftUI

struct ContentView: View {
    @State private var viewModel = PostViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.97, green: 0.94, blue: 1.0),
                        Color(red: 0.95, green: 0.98, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.posts.isEmpty {
                    emptyStateView
                } else {
                    postsListView
                }
            }
            .navigationTitle("RankBait")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showingAddPost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.blue)
                    }
                }
            }
            
            .sheet(isPresented: $viewModel.showingAddPost) {
                AddPostView{ post in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.addPost(post)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 56))
                .foregroundStyle(.blue.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("No Posts Yet")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Create the First Post")
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
            LazyVStack(spacing: 14) {
                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        onUpvote: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.upVote(post)
                            }
                        },
                        onDownvote: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.downVote(post)
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.deletePost(post)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    ContentView()
}
