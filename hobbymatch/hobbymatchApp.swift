//
//  hobbymatchApp.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/16.
//

// TODO: ファイル分け

@preconcurrency import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI
import UIKit

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

@MainActor
@Observable
final class AuthViewModel {
    private(set) var user: AuthUser?

    @ObservationIgnored
    private let service: any AuthServiceProtocol

    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    init(
        service: any AuthServiceProtocol
    ) {
        self.service = service
        startObserving()
    }

    convenience init() {
        self.init(service: AuthService())
    }

    private func startObserving() {
        observationTask = Task {
            [weak self] in
            guard let stream = self?.service.authStateStream else { return }
            for await user in stream {
                self?.user = user
            }
        }
    }

    func signInWithGoogle() async {
        do {
            try await service.signInWithGoogle()
        } catch {
            print("Sign in failed: \(error)")
        }
    }

    func signOut() {
        try? service.signOut()
    }

    deinit {
        observationTask?.cancel()
    }
}

struct AuthUser: Sendable, Equatable, Identifiable {
    let id: String
    let displayName: String?
    let email: String?
    let photoURL: URL?
}

extension AuthUser {
    init?(from user: FirebaseAuth.User?) {
        guard let user else { return nil }
        id = user.uid
        displayName = user.displayName
        email = user.email
        photoURL = user.photoURL
    }
}

protocol AuthServiceProtocol {
    var authStateStream: AsyncStream<AuthUser?> { get }

    func signInWithGoogle() async throws

    func signOut() throws
}

final class AuthService: AuthServiceProtocol {
    let authStateStream: AsyncStream<AuthUser?>
    private let continuation: AsyncStream<AuthUser?>.Continuation
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        let (stream, continuation) = AsyncStream<AuthUser?>.makeStream()
        authStateStream = stream
        self.continuation = continuation

        continuation.yield(AuthUser(from: Auth.auth().currentUser))

        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            let user = AuthUser(from: firebaseUser)
            self?.continuation.yield(user)
        }
    }

    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        continuation.finish()
    }

    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("⚠️ clientID not found in FirebaseApp options")
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let rootVC = await MainActor.run { () -> UIViewController? in
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = scene.windows.first?.rootViewController
            else {
                return nil
            }
            return rootVC
        }

        guard let rootVC else { return }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)

        guard let idToken = result.user.idToken?.tokenString else {
            return
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        try await Auth.auth().signIn(with: credential)
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}

#Preview {
    LoginView()
}
