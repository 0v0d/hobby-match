//
//  UserProfileServiceProtocol.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/21.
//

protocol UserProfileServiceProtocol: Sendable {
    func create(uid: String, profile: UserProfile) async throws
    func fetch(uid: String) async throws -> UserProfile?
    func update(uid: String, profile: UserProfile) async throws
    func fetchAll() async throws -> [UserProfile]
    func profilesStream() -> AsyncThrowingStream<[UserProfile], Error>
}
