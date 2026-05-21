//
//  LoginView.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var viewModel

    var body: some View {
        Button(action: {
            Task {
                await viewModel.signInWithGoogle()
            }
        }) {
            Text("ログイン")
        }
    }
}
