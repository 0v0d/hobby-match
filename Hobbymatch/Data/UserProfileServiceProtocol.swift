//
//  UserProfileServiceProtocol.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/21.
//

@preconcurrency import FirebaseFirestore

protocol UserProfileServiceProtocol: Sendable {
    func create(uid: String, profile: UserProfile) async throws
    func fetch(uid: String) async throws -> UserProfile?
    func update(uid: String, profile: UserProfile) async throws
    func fetchAll() async throws -> [UserProfile]
    func profilesStream() -> AsyncThrowingStream<[UserProfile], Error>
}

final class UserProfileService: UserProfileServiceProtocol {
    private let collection: CollectionReference
    private let collectionPath = "user_profiles"

    init(firebase: Firestore = Firestore.firestore()) {
        collection = firebase.collection(collectionPath)
    }

    func create(uid: String, profile: UserProfile) async throws {
        let document = collection.document(uid)

        let snapshot = try await document.getDocument()
        guard !snapshot.exists else {
            throw UserProfileError.alreadyExists
        }
        try document.setData(from: profile)
    }

    func fetch(uid: String) async throws -> UserProfile? {
        let document = try await collection.document(uid).getDocument()
        guard document.exists else {
            return nil
        }
        return try document.data(as: UserProfile.self)
    }

    func update(uid: String, profile: UserProfile) async throws {
        let document = collection.document(uid)

        guard try await document.getDocument().exists else {
            throw UserProfileError.notFound
        }

        var data: [String: Any] = [
            "displayName": profile.displayName,
            "bio": profile.bio,
            "hobbies": profile.hobbies,
            "updatedAt": FieldValue.serverTimestamp(),
        ]

        if let photoURL = profile.photoURL {
            data["photoURL"] = photoURL.absoluteString
        }

        try await document.updateData(data)
    }

    func fetchAll() async throws -> [UserProfile] {
        let snapshot = try await collection.getDocuments()
        return try snapshot.documents.compactMap { document in
            do {
                return try document.data(as: UserProfile.self)
            } catch {
                throw UserProfileError
                    .failDecode(
                        documentID: document.documentID,
                        underlying: error
                    )
            }
        }
    }

    func profilesStream() -> AsyncThrowingStream<[UserProfile], Error> {
        AsyncThrowingStream { continuation in
            let listener = collection.addSnapshotListener { snapshot, error in
                guard let snapshot else {
                    continuation.finish(throwing: error ?? UserProfileError.notFound)
                    return
                }

                let profiles = snapshot.documents.compactMap {
                    try? $0.data(as: UserProfile.self)
                }
                continuation.yield(profiles)
            }

            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}

enum UserProfileError: Error {
    case notFound
    case alreadyExists
    case failDecode(documentID: String, underlying: Error)
}
