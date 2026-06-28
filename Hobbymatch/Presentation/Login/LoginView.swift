//
//  LoginView.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import SwiftUI

struct LoginView: View {
    @Environment(SessionViewModel.self) private var viewModel

    var body: some View {
        Button {
            Task {
                await viewModel.signInWithGoogle()
            }
        } label: {
            Text("ログイン")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
