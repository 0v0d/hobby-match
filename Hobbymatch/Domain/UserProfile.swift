//
//  UserProfile.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/21.
//

import FirebaseFirestore

struct UserProfile: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var displayName: String
    var bio: String
    var hobbies: [String]
    var photoURL: URL?
    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var updatedAt: Date?
}
