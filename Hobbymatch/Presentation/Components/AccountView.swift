//
//  AccountView.swift
//  Hobbymatch
//
//  Created by 0v0 on 2026/06/07.
//

import SwiftUI

struct AccountView: View {
    let profile: UserProfile
    var body: some View {
        VStack {
            AsyncImage(url: profile.photoURL) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.quaternary, lineWidth: 1)
            }

            Text(profile.displayName)
                .font(.title2.bold())

            if !profile.bio.isEmpty {
                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if !profile.hobbies.isEmpty {
                HobbyTagsView(hobbies: profile.hobbies)
            }
        }.padding(8)
    }
}

private struct HobbyTagsView: View {
    let hobbies: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(hobbies, id: \.self) { hobby in
                    Text(hobby)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.tint.opacity(0.15), in: Capsule())
                        .foregroundStyle(.tint)
                }
            }
        }
    }
}
