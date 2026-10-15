//
//  MatchListViewModel.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/07/01.
//

import Observation

@MainActor
@Observable
final class MatchListViewModel {
    private let currentUserId: String

    private(set) var profiles: [UserProfile] = []

    private(set) var errorMessage: String?

    @ObservationIgnored
    private let matchService: any MatchServiceProtocol

    @ObservationIgnored
    private let userProfileService: any UserProfileServiceProtocol

    @ObservationIgnored
    private var observationTask: Task<Void, Never>?

    private var profileCache: [String: UserProfile] = [:]

    init(currentUserId: String,
         matchService: any MatchServiceProtocol = MatchService(),
         userProfileService: any UserProfileServiceProtocol = UserProfileService()
    ) {
        self.currentUserId = currentUserId
        self.matchService = matchService
        self.userProfileService = userProfileService
        startObserving()
    }

    deinit {
        observationTask?.cancel()
    }

    private func startObserving() {
        let currentUserId = currentUserId
        observationTask =  Task{
            [weak self] in
            guard let stream = self?.matchService.matchStream(
                uid: currentUserId
            ) else {
                return
            }

            do {
                for try await matches in stream {
                    let partnerIds = matches.compactMap { $0.users.first { $0 != currentUserId } }
                    var resolved: [UserProfile] = []
                    for uid in partnerIds {
                        if let profile = await self?.fetchProfile(uid: uid) {
                            resolved.append(profile)
                        }
                    }
                    self?.profiles = resolved
                }
            } catch {
                guard !Task.isCancelled else { return }
                self?.errorMessage = "プロフィール一覧の取得に失敗しました"
            }
        }
    }

    private func fetchProfile(uid: String) async -> UserProfile? {
        if let cached = profileCache[uid] {
            return cached
        }
        guard let fetched = try? await userProfileService.fetch(uid: uid) else {
            return nil
        }
        profileCache[uid] = fetched
        return fetched
    }
}
