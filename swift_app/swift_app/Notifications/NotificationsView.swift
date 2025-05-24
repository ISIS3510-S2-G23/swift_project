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
            VStack {
                // Network status indicator
                if !notificationService.isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.orange)
                        Text("Offline Mode - Notifications will not be updated")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }

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
                        Spacer().frame(height: 20)
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
        }
    }

    private func handleNotificationTap(_ notification: AppNotification) {
        notificationService.markAsRead(notification.id)

        switch notification.type {
        case .upvote:
            print("Viewing post that was upvoted: \(notification.postTitle ?? "")")
        case .forumPost:
            print("Viewing post in forum: \(notification.forumName ?? "")")
        case .newPost:
            print("Viewing new post")
        }
    }

    // Notification Cell View
    struct AppNotificationCell: View {
        let notification: AppNotification

        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                // Icon
                notificationIcon
                    .frame(width: 40, height: 40)
                    .background(iconBackground)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.system(size: 16))
                        .fontWeight(.medium)

                    Text(notification.message)
                        .font(.system(size: 14))
                        .foregroundColor(.primary.opacity(0.8))
                        .lineLimit(2)

                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.7))

                        Text("Just now")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }

                Spacer()

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

        private var iconBackground: Color {
            switch notification.type {
            case .upvote:
                return Color.green.opacity(0.15)
            case .newPost, .forumPost:
                return Color.blue.opacity(0.15)
            }
        }
    }
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(selectedView: .constant(3))
    }
}
