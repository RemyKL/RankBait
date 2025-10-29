import SwiftUI

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var friendName: String = ""
    @State private var content: String = ""
    let onAdd: (Post) -> Void
    var isValid: Bool {
        !friendName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
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
                
                Form {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                            
                            TextField("Friend's Name:", text: $friendName)
                                .font(.system(.body, design: .default))
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("WHO")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .tracking(0.5)
                    }
                    
                    Section {
                        TextEditor(text: $content)
                            .font(.system(.body, design: .default))
                            .frame(minHeight: 140)
                            .scrollContentBackground(.hidden)
                    } header: {
                        Text("WHAT")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .tracking(0.5)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newPost = Post(
                            friendName: friendName.trimmingCharacters(in: .whitespaces),
                            content: content.trimmingCharacters(in: .whitespaces))
                        onAdd(newPost)
                        dismiss()
                    }
                    .disabled(!isValid)
                    .foregroundStyle(.blue)
                    .fontWeight(.semibold)
                }
            }
        }
        
    }
}
