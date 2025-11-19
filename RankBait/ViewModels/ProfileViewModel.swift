//
//  ProfileViewModel.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//
//
//  ProfileViewModel.swift
//  RankBait
//
//  Created by Remy Laurens on 11/16/25.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI

@MainActor // Use @MainActor for thread safety with @Published
class ProfileViewModel : ObservableObject {
    
    @Published var username: String = "Loading..."
    @Published var user: User?
    @Published var numPosts: Int = 0
    @Published var totalVotes: Int = 0
    @Published var numMentions: Int = 0
    
    @Published var usernameInput: String = ""
    @Published var isSaving = false
    @Published var saveError: Error? = nil
    // We make userId private as well; the view should observe 'username', not 'userId' directly.
    private var userId: String
    private var groupId: String
    private var numVotes: Int = 0
    
    // Accept the required IDs in the initializer
    init(userId: String, groupId: String) {
        // !! CRITICAL FIX HERE !!
        // You should use the 'userId' passed into the initializer parameter,
        // not try to fetch it again inside the init using a separate function.
        self.userId = userId
        
        self.groupId = groupId
        
        // Use a Task to call the async function from the sync init
        Task {
            await loadUser()
        }
    }
    
    func updateGroupId(newGroupId: String) async {
        guard self.groupId != newGroupId else { return }
        
        self.groupId = newGroupId
        await loadUser()
    }
    
    func loadUser() async {
        do {
            // Use the stored userId and groupId
            if let fetchedUser = try await UserService.shared.fetchFullUser(forUserId: userId) {
                self.user = fetchedUser
                self.username = fetchedUser.nicknames[groupId] ?? "Unknown"
            } else {
                self.username = "User Not Found"
                self.user = nil
            }
            
            self.numPosts = try await UserService.shared.countUserPosts(forUserId: userId, forGroupId: groupId)
            self.totalVotes = try await UserService.shared.calculateTotalVotes(forUserId: userId, forGroupId: groupId)
            self.numMentions = try await UserService.shared.calculateUserMentions(forUserId: userId, forGroupId: groupId)
        } catch {
            print("Error loading username: \(error)")
            self.username = "Error"
        }
    }
//
//    func updateUsername(_ newUsername: String) {
//            // UserProfileManager.shared.setUsername(newUsername) // Assuming this is defined
//            username = newUsername
//        }
    func saveNickname() async {
        guard usernameInput != username else { return }
            saveError = nil
            
            do {
                // Assuming you have a function in UserService to update a specific nickname in Firebase
                try await UserService.shared.updateNickname(userId: userId, groupId: groupId, newNickname: usernameInput)
                
                // Refresh local data from the cache/database to confirm update
                await loadUser()
                
            } catch {
                self.saveError = error
                print("Error saving nickname: \(error.localizedDescription)")
            }
        }
    
    func uploadProfilePicture(image: UIImage) async {
        do {
            try await UserService.shared.uploadProfileImage(image, forUserId: userId)
            await loadUser()
        } catch {
            print("error uploading profile picture")
        }
    }
    
    func saveProfileChanges(image: UIImage?) async {
            guard !isSaving else { return }
            isSaving = true // Set loading true at the start
            
            do {
                if let imageToUpload = image {
                    // Call the upload function
                    try await UserService.shared.uploadProfileImage(imageToUpload, forUserId: userId)
                }
                
                // Call the nickname function
                try await UserService.shared.updateNickname(userId: userId, groupId: groupId, newNickname: usernameInput)
                
                // After successful save, reload user data to reflect all changes
                await loadUser()

            } catch {
                self.saveError = error
                print("Comprehensive Save Error: \(error.localizedDescription)")
            }
            
            isSaving = false // Set loading false at the end
        }
    
}
