//
//  LikeServiceProtocol.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/14.
//

protocol LikeServiceProtocol {
    func hasLiked(like: Like) async throws -> Bool
    func sendLike(like: Like) async throws
}
