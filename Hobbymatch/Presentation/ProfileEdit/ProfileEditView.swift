//
//  ProfileEditView.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/05/31.
//

import SwiftUI

struct ProfileEditView: View {
    let user: AuthUser
    @Environment(SessionViewModel.self) private var sessionViewModel
    @State private var viewModel = ProfileEditViewModel()

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var hobbiesText: String = ""

    private var canSave: Bool {
        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        return !viewModel.isSaving
            && !trimmedDisplayName.isEmpty
            && trimmedDisplayName.count <= 50
            && bio.count <= 300
    }

    init(user: AuthUser) {
        self.user = user
        _displayName = State(initialValue: user.displayName ?? "")
    }

    var body: some View {
        Form {
            Section("基本情報") {
                TextField("表示名", text: $displayName)
                TextField("自己紹介", text: $bio, axis: .vertical)
                    .lineLimit(3 ... 6)
            }
            Section("趣味") {
                TextField("趣味(カンマ区切り)", text: $hobbiesText)
            }
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(Color.red)
            }
            Section {
                Button("保存") {
                    Task {
                        await save()
                    }
                }.disabled(!canSave)
            }
        }.navigationTitle("プロフィール作成")
    }

    private func save() async {
        let hobbies = hobbiesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)

        let profile = UserProfile(
            id: nil,
            displayName: trimmedDisplayName,
            bio: trimmedBio,
            hobbies: hobbies,
            photoURL: user.photoURL,
            createdAt: nil,
            updatedAt: nil
        )

        let success = await viewModel.save(profile, uid: user.id)
        if success {
            await sessionViewModel.loadUserProfile(user: user)
        }
    }
}
