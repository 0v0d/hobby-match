//
//  Match.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/29.
//
import FirebaseFirestore

struct Match: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    let users:[String]
    @ServerTimestamp var createdAt: Date?
}
