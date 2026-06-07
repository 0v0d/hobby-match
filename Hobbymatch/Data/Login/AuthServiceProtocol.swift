//
//  AuthServiceProtocol.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

protocol AuthServiceProtocol {
    var authStateStream: AsyncStream<AuthUser?> { get }

    func signInWithGoogle() async throws

    func signOut() throws
}
