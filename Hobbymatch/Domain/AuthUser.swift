//
//  AuthUser.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import FirebaseAuth
import Foundation

struct AuthUser: Sendable, Equatable, Identifiable {
    let id: String
    let displayName: String?
    let email: String?
    let photoURL: URL?
}

extension AuthUser {
    init?(from user: FirebaseAuth.User?) {
        guard let user else { return nil }
        id = user.uid
        displayName = user.displayName
        email = user.email
        photoURL = user.photoURL
    }
}
