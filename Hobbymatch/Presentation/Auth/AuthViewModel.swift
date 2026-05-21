//
//  AuthViewModel.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import Observation

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
