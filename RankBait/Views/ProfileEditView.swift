//
//  ProfileEditView.swift
//  RankBait
//
//  Created by Remy Laurens on 11/18/25.
//
import PhotosUI
import SwiftUI
import SDWebImageSwiftUI

struct ProfileEditView: View {
    // We pass the existing ViewModel into the sheet/navigation view
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss // To close the view
    
    @State private var selectedImageItem : PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        // Display current profile picture or placeholder
                        if (profileImage == nil) {
                            if let urlString = viewModel.user?.profileImageUrl, let url = URL(string: urlString) {
                                WebImage(url: url) // Pass the URL to the initializer
                                    .resizable()   // Correct spelling
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                // Fallback to the system placeholder if no URL is available
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 100))
                                    .foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.8))
                            }
                        } else {
                            Image(uiImage: profileImage ?? UIImage(systemName: "person.crop.circle.fill")!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .padding(.vertical)
                        }
                        
                        Spacer()
                    }
                    PhotosPicker(
                        selection: $selectedImageItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Change Picture")
                    }
                }

                Section(header: Text("Nickname (for this group)")) {
                    TextField("Enter your nickname", text: $viewModel.usernameInput)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }

                if viewModel.saveError != nil {
                    Text("Error: Could not save changes.")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveChanges) {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(viewModel.isSaving || (viewModel.usernameInput == viewModel.username && profileImage == nil))
                }
            }
            // Sync the input field with the current VM username when the view appears/updates
            .onAppear {
                viewModel.usernameInput = viewModel.username
            }
            .onChange(of: selectedImageItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            self.profileImage = uiImage
                        }
                    }
                }
            }
        }
    }
    
    func saveChanges() {

        let imageToSave = profileImage
                
            Task {
                // Call the comprehensive save function
                await viewModel.saveProfileChanges(image: imageToSave)
                
                // Dismiss only if no final error occurred
                if viewModel.saveError == nil && !viewModel.isSaving {
                    dismiss()
                }
            }
    }
}
