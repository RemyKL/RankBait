import SwiftUI
import PhotosUI

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel : PostViewModel
    @State private var selectedMember: (key: String, value: String) = ("", "")
    @State private var content: String = ""
    @State private var members: [String : String] = [:]
    @State private var isLoadingMembers = true
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    let currentGroupId: String
//    let onAdd: (Post) -> Void
    
    var isValid: Bool {
        !selectedMember.key.isEmpty &&
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
                
                if isLoadingMembers {
                    ProgressView("Loading members...")
                        .font(.system(.body, design: .rounded))
                } else if members.isEmpty {
                    emptyMembersView
                } else {
                    contentView
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
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(.ultraThinMaterial)
//                                .shadow(color: .red.opacity(0.2), radius: 6, y: 3)
//                        )
                    }
                }
                
//                ToolbarItem(placement: .confirmationAction) {
//                    Button {
//                        let newPost = Post(
//                            groupId: currentGroupId,
//                            uid: selectedMember.key,
//                            posterid: UserService.shared.getuid() ?? "test",
//                            imageUrl: "",
//                            content: content.trimmingCharacters(in: .whitespaces))
//                        onAdd(newPost)
//                        dismiss()
//                    } label: {
//                        HStack(spacing: 6) {
//                            Image(systemName: "checkmark.circle.fill")
//                                .font(.body)
//                                .fontWeight(.semibold)
//                            
//                            Text("Add")
//                                .font(.system(.body, design: .rounded))
//                                .fontWeight(.bold)
//                        }
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: isValid
//                                    ? [Color.blue, Color.cyan]
//                                    : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                    }
//                    .disabled(!isValid)
//                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isValid)
//                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        // Call the new async function in the ViewModel
                        Task {
                            await handlePostCreation()
                        }
                    } label: {
                        // Show ProgressView if loading, otherwise show the text/icon
                        if viewModel.isPosting {
                            ProgressView()
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text("Add")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(
                                LinearGradient(
                                    colors: isValid
                                        ? [Color.blue, Color.cyan]
                                        : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                    // Disable if invalid OR if posting
                    .disabled(!isValid || viewModel.isPosting)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isValid)
                }
            }
            .onAppear {
                loadMembers()
            }
        }
    }
    

    func handlePostCreation() async {
        // 1. Get the current user's UID (assuming this is the user posting)
        guard let postingUserId = UserService.shared.getuid(),
              let currentGroupId = viewModel.currentGroupId // Assuming VM knows the group ID
        else {
            print("Error: Missing required data for posting.")
            return
        }
        if selectedMember.key == "" {
            print("no selected member")
            return
        }
        
        let targetMemberId = selectedMember.key

        // 2. Call the async function on the view model
        await viewModel.createPost(
            content: content,
            selectedMemberId: targetMemberId,
            userId: postingUserId,
            image: image // Pass the loaded UIImage
        )
        
        // 3. Dismiss the view only if the post was successful
        if !viewModel.isPosting { // isPosting should be false if the async function completed
            dismiss()
        }
    }
    
    private var emptyMembersView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Members Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Members Will Appear Here After Joining the Group")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 40)
    }
    
    private var contentView: some View {
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
                    
                    Menu {
                        ForEach(members.sorted(by: <), id: \.key) { key, value in
                            Button(value) {
                                selectedMember = (key, value)
                            }
                        }
                    } label: {
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
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(selectedMember.key.isEmpty ? "Select Member" : selectedMember.value)
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(selectedMember.value.isEmpty ? .regular : .medium)
                                    .foregroundStyle(selectedMember.value.isEmpty ? .secondary : .primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
                    }
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
                            Text("What Did They Do?")
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
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("PROOF")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack() {
                        PhotosPicker(
                            selection: $selectedImage,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            HStack {
                                Spacer()
                                Text("Upload an Image").font(.system(size: 16))
                                Image(systemName: "square.and.arrow.up").font(.system(size: 24)).padding(8)
                                Spacer()
                            }
                        }
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity) // Correct size
                                .cornerRadius(12)
                                .padding(8)
                        }
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
                .onChange(of: selectedImage) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            if let uiImage = UIImage(data: data) {
                                self.image = uiImage
                            }
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.top, 24)
        }
    }
    
    private func loadMembers() {
        Task {
            do {
                let fetched = try await GroupManager.shared.getMembersWithNicknames(for: currentGroupId)

                await MainActor.run {
                    members = fetched   // [String : String]
                    selectedMember = fetched.first ?? ("" , "User")
                    isLoadingMembers = false
                }

            } catch {
                await MainActor.run {
                    members = [:]
                    isLoadingMembers = false
                }
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
