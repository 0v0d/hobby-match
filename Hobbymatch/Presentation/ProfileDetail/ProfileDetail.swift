//
//  ProfileDetail.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/14.
//

import SwiftUI

struct ProfileDetailView: View {
    @State private var viewModel: ProfileDetailViewModel
    let profile: UserProfile

    init(currentUserId: String, profile: UserProfile) {
        self.profile = profile
        _viewModel = State(
            initialValue:
            ProfileDetailViewModel(
                currentUserId: currentUserId,
                toUserID: profile.id ?? ""
            )
        )
    }

    var body: some View {
        VStack {
            AccountView(profile: profile)
            LikeButton(
                isLiked: viewModel.isLiked,
                action: { await viewModel.sendLike() }
            )
            Spacer()
        }
        .task { await viewModel.loadInitialState() }
    }
}

struct LikeButton: View {
    let isLiked: Bool
    let action: () async -> Void
    var body: some View {
        Button { Task { await action() } } label: {
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .foregroundStyle(isLiked ? .red : .gray)
        }
        .disabled(isLiked)
    }
}
