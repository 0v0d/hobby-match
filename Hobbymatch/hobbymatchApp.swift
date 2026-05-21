//
//  hobbymatchApp.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/16.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct hobbymatchApp: App {
    @State private var viewModel: AuthViewModel

    init() {
        FirebaseApp.configure()
        _viewModel = State(initialValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if let user = viewModel.user {
                    MainView(user: user)
                } else {
                    LoginView()
                }
            }.environment(viewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

#Preview {
    LoginView()
}
