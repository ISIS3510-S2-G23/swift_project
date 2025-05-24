//
//  FiirebaseNotificationManager.swift
//  swift_app
//
//  Created by Paulina Arrazola on 20/05/25.
//
import Foundation
import FirebaseFirestore

class FirebaseNotificationManager {
    static let shared = FirebaseNotificationManager()
    private var db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    
    private init() {}
    
    func startListening(for userId: String) {
        // Clear any existing listeners
        stopListening()
        
        // Listen for upvotes on user's posts
        listenForUpvotes(userId: userId)
        
        // Listen for posts in forums
        listenForForumPosts(userId: userId)
    }
    
    private func listenForUpvotes(userId: String) {
        let listener = db.collection("posts")
            .whereField("user", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Process document changes
                for change in snapshot.documentChanges {
                    if change.type == .modified {
                        let data = change.document.data()
                        let postId = change.document.documentID
                        
                        let postTitle = data["text"] as? String
                        
                        if let upvotedBy = data["upvotedBy"] as? [[String: Any]] {
                            if let lastUpvote = upvotedBy.last,
                               let username = lastUpvote["0"] as? String {
                                
                                let notification = AppNotification(
                                    type: .upvote,
                                    title: "New upvote on your post",
                                    message: "User \(username) upvoted your post",
                                    timestamp: Date(),
                                    relatedPostId: postId,
                                    relatedUserId: username,
                                    relatedUserName: username,
                                    postTitle: postTitle
                                )
                                
                                // Add to notification service
                                DispatchQueue.main.async {
                                    AppNotificationService.shared.notifications.insert(notification, at: 0)
                                }
                            }
                        }
                    }
                }
            }
        
        listeners.append(listener)
    }
    
    private func listenForForumPosts(userId: String) {
    }
    
    func stopListening() {
        for listener in listeners {
            listener.remove()
        }
        listeners.removeAll()
    }
}
