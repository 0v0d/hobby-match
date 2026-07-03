//
//  LikeService.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/29.
//

@preconcurrency import FirebaseFirestore

final class LikeService: LikeServiceProtocol {
    private let collection: CollectionReference
    private let collectionPath = "likes"

    init(firebase: Firestore = Firestore.firestore()) {
        collection = firebase.collection(collectionPath)
    }

    func hasLiked(like: Like) async throws -> Bool {
        let documentId = "\(like.fromUserId)_\(like.toUserId)"
        let snapshot = try await collection.document(documentId).getDocument()
        return snapshot.exists
    }

    func sendLike(like: Like) async throws {
        let documentId = "\(like.fromUserId)_\(like.toUserId)"
        try collection.document(documentId).setData(from: like)
    }
}
