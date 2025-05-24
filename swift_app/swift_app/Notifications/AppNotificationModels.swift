//
//  NotificationModels.swift
//  swift_app
//
//  Created by Paulina Arrazola on 20/05/25.
//

import Foundation
import FirebaseFirestore
import Network

enum AppNotificationType: String, Codable {
    case upvote = "upvote"
    case newPost = "newPost"
    case forumPost = "forumPost"
}

struct AppNotification: Identifiable {
    var id = UUID().uuidString
    var type: AppNotificationType
    var title: String
    var message: String
    var timestamp: Date
    var read: Bool = false
    var relatedPostId: String?
    var relatedUserId: String?
    var relatedUserName: String?
    var postTitle: String?
    var forumId: String?
    var forumName: String?
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

class AppNotificationService: ObservableObject {
    @Published var notifications: [AppNotification] = []
    private var db = Firestore.firestore()
    private let networkMonitor = NWPathMonitor()
    @Published private(set) var isConnected = true
    
    static let shared = AppNotificationService()
    
    private init() {
        fetchNotifications()
        setupNetworkMonitoring()
    }
    deinit {
        networkMonitor.cancel()
    }
    
    func fetchNotifications() {
        // Sample notifications with descriptive information
        notifications = [
            AppNotification(
                type: .upvote,
                title: "New upvote on your post",
                message: "User mock16 upvoted your post about sustainability",
                timestamp: Date(),
                relatedPostId: "5FVePh1fWqFBVUTrzL7y",
                relatedUserId: "mock16",
                relatedUserName: "mock16",
                postTitle: "Prueba con tags (ver si registra el evento)"
            ),
            
            AppNotification(
                type: .forumPost,
                title: "Post added to forum",
                message: "Your post about sustainability was added to Recycling forum",
                timestamp: Date().addingTimeInterval(-60),
                relatedPostId: "5FVePh1fWqFBVUTrzL7y",
                postTitle: "Prueba con tags (ver si registra el evento)",
                forumId: "1",
                forumName: "Recycling"
            ),
            
            AppNotification(
                type: .forumPost,
                title: "Post added to forum",
                message: "Your post about recycling was added to Sustainability forum",
                timestamp: Date().addingTimeInterval(-120),
                relatedPostId: "5FVePh1fWqFBVUTrzL7y",
                postTitle: "Prueba con tags (ver si registra el evento)",
                forumId: "2",
                forumName: "Sustainability"
            )
        ]
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = (path.status == .satisfied)
                if !wasConnected && self?.isConnected == true {
                    print("Network reconnected")
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    func markAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].read = true
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i].read = true
        }
    }
}
