//
//  NicknameView.swift
//  RankBait
//
//  Created by Remy Laurens on 11/18/25.
//

import SwiftUI

struct NicknameView : View {
    let uid : String
    let groupId : String
    @State private var nickname : String = "Loading..."
    
    var body: some View {
        Text(nickname)
            .task {
                self.nickname = (try? await UserService.shared.getNickname(forUserId: uid, inGroup: groupId)) ?? "Unknown"
            }
            
    }
}
