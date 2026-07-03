//
//  MatchListView.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/29.
//

import SwiftUI

struct MatchListView :View {
    @State private var viewModel: MatchListViewModel
    private let currentUserId: String

    init(currentUserId: String) {
        self.currentUserId = currentUserId
        _viewModel = State(
            initialValue: MatchListViewModel(currentUserId: currentUserId)
        )
    }

    var body: some View {
        NavigationStack{
            UserProfileListComponent(
                errorMessage: viewModel.errorMessage,
                profiles: viewModel.profiles,
                currentUserId: currentUserId
            )
        }
    }
}
