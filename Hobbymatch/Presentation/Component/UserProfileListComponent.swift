//
//  UserProfileListComponent.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/07/01.
//

import SwiftUI

struct UserProfileListComponent: View{
    let errorMessage: String?
    let profiles: [UserProfile]
    let currentUserId: String

    var body: some View {
        VStack {
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
            } else if !profiles.isEmpty {
                List(profiles) {
                    profile in
                    NavigationLink(value: profile) {
                        Text(profile.displayName)
                    }
                }
            } else {
                Text("まだ誰もいません")
            }
        }.navigationDestination(for: UserProfile.self) { selectedProfile in
            ProfileDetailView(
                currentUserId: currentUserId,
                profile: selectedProfile
            )
        }
    }
}
