//
//  hobbymatchApp.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/16.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@main
struct hobbymatchApp: App {
    @State private var viewModel: SessionViewModel

    init() {
        FirebaseApp.configure()
        #if DEBUG
        let settings = Firestore.firestore().settings
        settings.host = "127.0.0.1:8080"
        settings.isSSLEnabled = false
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
        #endif
        _viewModel = State(initialValue: SessionViewModel())
    }

    var body: some Scene {
        WindowGroup {
            AppNavigation()
                .environment(viewModel)
        }
    }
}

struct AppNavigation: View {
    @Environment(SessionViewModel.self) private var sessionViewModel

    var body: some View {
        NavigationStack {
            switch sessionViewModel.state {
            case .loading:
                ProgressView()
            case .unauthorized:
                LoginView()
            case let .authorizedWithoutProfile(user):
                ProfileEditView(user: user)
            case let .authorized(user, profile):
                MainView(user: user, profile: profile)
            }
        }
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

#Preview {
    LoginView()
}
