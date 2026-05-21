//
//  AuthService.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

@preconcurrency import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

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
