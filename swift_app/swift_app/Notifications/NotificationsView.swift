//
//  NotificationsView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/17/25.
//
import SwiftUI

struct NotificationsView: View {
    @Binding var selectedView: Int
    @StateObject private var notificationService = AppNotificationService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Notifications")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            ScrollView {
                VStack(spacing: 10) {
                    // List of notifications
                    ForEach(notificationService.notifications) { notification in
                        AppNotificationCell(notification: notification)
                            .onTapGesture {
                                handleNotificationTap(notification)
                            }
                    }
                    
                    // Empty state if no notifications
                    if notificationService.notifications.isEmpty {
                        VStack(spacing: 20) {
                            Spacer().frame(height: 60)
                            Image(systemName: "bell.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Text("No notifications yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("You'll see updates about your posts and activity here")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    
                    // Add empty space at bottom
                    Spacer().frame(height: 20)
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
    
    // Handle notification tap directly within this view
    private func handleNotificationTap(_ notification: AppNotification) {
        // Mark notification as read
        notificationService.markAsRead(notification.id)
        
        // Navigation logic would go here
        // For now we'll just print the action
        switch notification.type {
        case .upvote:
            print("Viewing post that was upvoted: \(notification.postTitle ?? "")")
        case .forumPost:
            print("Viewing post in forum: \(notification.forumName ?? "")")
        case .newPost:
            print("Viewing new post")
        }
    }
}

// Renamed to avoid conflicts with system notification components
struct AppNotificationCell: View {
    let notification: AppNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon for notification type
            notificationIcon
                .frame(width: 40, height: 40)
                .background(iconBackground)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                
                // More descriptive message
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(.primary.opacity(0.8))
                    .lineLimit(2)
                
                // Timestamp
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.7))
                    
                    Text("Just now")  // In a real app, use notification.timeAgo
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Unread indicator
            if !notification.read {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
    
    // Different icons for different notification types
    private var notificationIcon: some View {
        Group {
            switch notification.type {
            case .upvote:
                Image(systemName: "arrow.up.circle")
                    .font(.system(size: 20))
                    .foregroundColor(Color.green)
            case .newPost, .forumPost:
                Image(systemName: "bubble.left")
                    .font(.system(size: 20))
                    .foregroundColor(Color.blue)
            }
        }
    }
    
    // Different background colors for different notification types
    private var iconBackground: Color {
        switch notification.type {
        case .upvote:
            return Color.green.opacity(0.15)
        case .newPost, .forumPost:
            return Color.blue.opacity(0.15)
        }
    }
}

// Preview with the required Binding parameter
#Preview {
    NotificationsView(selectedView: .constant(3))
}

// Preview with the required Binding parameter
#Preview {
    NotificationsView(selectedView: .constant(3))
}
