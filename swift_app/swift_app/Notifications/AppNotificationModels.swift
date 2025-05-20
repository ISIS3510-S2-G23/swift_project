//
//  NotificationModels.swift
//  swift_app
//
//  Created by Paulina Arrazola on 20/05/25.
//
import Foundation
import FirebaseFirestore

// Renamed to avoid conflicts with NSNotification
enum AppNotificationType: String, Codable {
    case upvote = "upvote"
    case newPost = "newPost"
    case forumPost = "forumPost"
}

// Renamed to avoid conflicts with system notifications
struct AppNotification: Identifiable {
    var id = UUID().uuidString
    var type: AppNotificationType
    var title: String
    var message: String // More detailed message
    var timestamp: Date
    var read: Bool = false
    var relatedPostId: String?
    var relatedUserId: String?
    var relatedUserName: String? // Name of the user who performed the action
    var postTitle: String? // Title of the related post
    var forumId: String?
    var forumName: String? // Name of the forum
    
    // For easy timestamp display
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

class AppNotificationService: ObservableObject {
    @Published var notifications: [AppNotification] = []
    private var db = Firestore.firestore()
    
    // Using singleton pattern without parameters to avoid warnings
    static let shared = AppNotificationService()
    
    private init() {
        fetchNotifications()
    }
    
    func fetchNotifications() {
        // Sample notifications with more descriptive information
        notifications = [
            // Someone upvoted your post
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
            
            // Your post was added to a forum
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
            
            // Another forum post
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
