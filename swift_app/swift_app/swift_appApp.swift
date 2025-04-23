//
//  swift_appApp.swift
//  swift_app
//
//  Created by Paulina Arrazola on 24/01/25.
//

import SwiftUI
import FirebaseCore

@main
struct swift_appApp: App {
    init() {
        FirebaseApp.configure()
        _ = NetworkMonitor.shared
        _ = PostSyncManager.shared
        // trigger sync at launch if online
        if NetworkMonitor.shared.isConnected {
            PostSyncManager.shared.syncPendingPosts()
        }
    }
    var body: some Scene {
        WindowGroup {
            WelcomeView1()
        }
    }
}
