//
//  MyAccountView.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/07.
//

import SwiftUI

struct MyAccountView: View {
    @Environment(SessionViewModel.self) private var viewModel
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                AccountView(profile: profile)

                Button(role: .destructive) {
                    viewModel.signOut()
                } label: {
                    Text("ログアウト")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(24)
        }
    }
}
