//
//  MatchService.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/29.
//

@preconcurrency import FirebaseFirestore

final class MatchService : MatchServiceProtocol{
    private let collection: CollectionReference
    private let collectionPath = "matches"

    init(firebase: Firestore = Firestore.firestore()) {
        collection = firebase.collection(collectionPath)
    }

    func matchStream(uid: String) -> AsyncThrowingStream<[Match], any Error> {
        let query = collection
                .whereField("users", arrayContains: uid)
                .order(by: "createdAt", descending: true)

      return AsyncThrowingStream { continuation in
            let listener = query.addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    continuation.finish(throwing: error)
                    return
                }

                let profiles = snapshot.documents.compactMap {
                    try? $0.data(as: Match.self)
                }
                continuation.yield(profiles)
            }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}
