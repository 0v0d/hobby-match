//
//  MainView.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import SwiftUI

struct MainView: View {
    @Environment(AuthViewModel.self) private var viewModel
    let user: AuthUser

    var body: some View {
        VStack {
            Text(user.displayName ?? "ナナシさん")
            AsyncImage(url: user.photoURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            Button(action: {
                viewModel.signOut()
            }) {
                Text("ログアウト")
            }
        }
    }
}
