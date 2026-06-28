//
//  SessionViewModel.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import Observation

@MainActor
@Observable
final class SessionViewModel {
    enum State {
        case loading
        case unauthorized
        case authorizedWithoutProfile(AuthUser)
        case authorized(AuthUser, UserProfile)
    }

    private(set) var state: State = .loading

    @ObservationIgnored
    private let authService: any AuthServiceProtocol

    @ObservationIgnored
    private let userProfileService: any UserProfileServiceProtocol

    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    init(
        authService: any AuthServiceProtocol = AuthService(),
        userProfileService: any UserProfileServiceProtocol = UserProfileService()
    ) {
        self.authService = authService
        self.userProfileService = userProfileService
        startObserving()
    }

    deinit {
        observationTask?.cancel()
    }

    func signInWithGoogle() async {
        do {
            try await authService.signInWithGoogle()
        } catch {
            print("Sign in failed: \(error)")
        }
    }

    func signOut() {
        try? authService.signOut()
    }

    private func startObserving() {
        observationTask = Task {
            [weak self] in
            guard let stream = self?.authService.authStateStream else { return }
            for await user in stream {
                await self?.onAuthChange(user)
            }
        }
    }

    private func onAuthChange(_ authUser: AuthUser?) async {
        print("[DEBUG] onAuthChange user=\(authUser?.id ?? "nil")")
        guard let user = authUser else {
            state = .unauthorized
            return
        }
        await loadUserProfile(user: user)
    }

    func loadUserProfile(user: AuthUser) async {
        print("[DEBUG] loadUserProfile start uid=\(user.id)")
        do {
            guard let userProfile = try await userProfileService.fetch(
                uid: user.id
            ) else {
                state = .authorizedWithoutProfile(user)
                return
            }
            state = .authorized(user, userProfile)

        } catch {
            print("プロフィール取得エラー: \(error)")
            signOut()
        }
    }
}
