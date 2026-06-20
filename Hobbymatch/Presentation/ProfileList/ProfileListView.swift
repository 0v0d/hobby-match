//
//  ProfileListView.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/31.
//

import SwiftUI

struct ProfileListView: View {
    @Environment(SessionViewModel.self) private var sessionViewModel
    @State private var viewModel: ProfileListViewModel
    private let currentUserId: String

    init(currentUserId: String) {
        self.currentUserId = currentUserId
        _viewModel = State(
            initialValue: ProfileListViewModel(currentUserId: currentUserId)
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                } else if !viewModel.profiles.isEmpty {
                    List(viewModel.profiles) {
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
}
