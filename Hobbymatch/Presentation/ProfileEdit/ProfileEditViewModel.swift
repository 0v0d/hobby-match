//
//  ProfileEditViewModel.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/31.
//

import Observation

@MainActor
@Observable
final class ProfileEditViewModel {
    @ObservationIgnored
    private let profileService: any UserProfileServiceProtocol
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    init(
        profileService: UserProfileServiceProtocol = UserProfileService()
    ) {
        self.profileService = profileService
    }

    func save(_ profile: UserProfile, uid: String) async -> Bool {
        isSaving = true
        errorMessage = nil

        defer { isSaving = false }

        do {
            try await profileService.create(uid: uid, profile: profile)
            return true
        } catch UserProfileError.alreadyExists {
            errorMessage = "プロフィールはすでに作成されています"
            return false
        } catch {
            errorMessage = "保存に失敗しました"
            return false
        }
    }
}
