//
//  MainView.swift
//  hobbymatch
//
//  Created by 0v0 on 2026/05/20.
//

import SwiftUI

struct MainView: View {
    let user: AuthUser
    let profile: UserProfile

    var body: some View {
        TabView {
            Tab("友達を探す", systemImage: "magnifyingglass") {
                ProfileListView(currentUserId: user.id)
            }
            Tab("アカウント", systemImage: "person") {
                MyAccountView(profile: profile)
            }
            Tab("マッチ", systemImage: "heart") {
                MatchListView(currentUserId:user.id)
            }
        }
    }
}
