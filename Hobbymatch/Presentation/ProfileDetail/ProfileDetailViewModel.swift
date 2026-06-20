//
//  ProfileDetailViewModel.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/14.
//

import Observation
import Foundation

@MainActor
@Observable
final class ProfileDetailViewModel {
    @ObservationIgnored
    private let likeService: any LikeServiceProtocol
    private let currentUserId: String
    private let toUserID: String

    private(set) var isLiked: Bool = false

    private(set) var errorMessage: String?

    init(currentUserId: String, toUserID: String, likeService: any LikeServiceProtocol = LikeService()) {
        self.currentUserId = currentUserId
        self.toUserID = toUserID
        self.likeService = likeService
    }

    func loadInitialState() async {
        do {
            isLiked = try await hasLiked()
        } catch {
            errorMessage = "状態取得失敗: \(error.localizedDescription)"
        }
    }

    func hasLiked() async throws -> Bool {
        do {
            return try await likeService.hasLiked(
                like: Like(
                    fromUserId: currentUserId,
                    toUserId: toUserID
                )
            )
        } catch {
            print("[ProfileDetailViewModel] hasLiked failed: \(error)")
            throw error
        }
    }

    func sendLike() async  {
        do {
            try await likeService.sendLike(
                like: Like(
                    fromUserId: currentUserId,
                    toUserId: toUserID
                )
            )
            isLiked = true
        }catch {
            isLiked = false
            errorMessage = error.localizedDescription
        }
    }
}
