//
//  ProfileListViewModel.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/31.
//

import Observation

@MainActor
@Observable
final class ProfileListViewModel {
    private(set) var profiles: [UserProfile] = []

    @ObservationIgnored
    private let userProfileService: any UserProfileServiceProtocol

    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    private let currentUserId: String

    private(set) var errorMessage: String?

    init(
        currentUserId: String,
        userProfileService: any UserProfileServiceProtocol = UserProfileService()
    ) {
        self.userProfileService = userProfileService
        self.currentUserId = currentUserId
        startObserving()
    }

    deinit {
        observationTask?.cancel()
    }

    private func startObserving() {
        let currentUserId = currentUserId
        observationTask = Task {
            [weak self] in
            guard let stream = self?.userProfileService.profilesStream() else { return }
            do {
                for try await profiles in stream {
                    self?.profiles = profiles.filter { $0.id != currentUserId }
                }
            } catch {
                // 画面やViewModelが破棄されてobservationTask?.cancel()された場合にもstreamが終了するので、
                // そのときの終了を普通のエラーっぽく扱わないため
                guard !Task.isCancelled else { return }
                print("プロフィール購読エラー: \(error)")
                self?.errorMessage = "プロフィール一覧の取得に失敗しました"
            }
        }
    }
}
