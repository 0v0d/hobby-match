//
//  Like.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/13.
//

import FirebaseFirestore

struct Like: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    let fromUserId: String
    let toUserId: String
    @ServerTimestamp var createdAt: Date?
}
