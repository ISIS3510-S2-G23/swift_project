//
//  CommentCacheManager.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 5/15/25.
//
import Foundation
import UIKit

struct CachedComment: Codable {
    let postId: String
    let updatedComments: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case postId, updatedComments
    }
}

class CommentCacheManager {
    static let shared = CommentCacheManager()
    
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let postQueueKey = "pendingComments"
    
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("PendingComments")
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("Error creating cache directory: \(error.localizedDescription)")
        }
    }
    
    // Save comment to persistent cache
    func cacheComment(pPostId: String, pUpdatedComments: [String: String]) -> String {
        let newCommentId = UUID().uuidString
        
        let cachedComments = CachedComment(
            postId: pPostId,
            updatedComments: pUpdatedComments
        )
        
        do {
            let data = try JSONEncoder().encode(cachedComments)
            try data.write(to: cacheDirectory.appendingPathComponent(newCommentId))
            savePendingCommentId(newCommentId)
            return newCommentId
        } catch {
            print("Error caching comment: \(error.localizedDescription)")
            return ""
        }
    }
    
    func getPendingComments() -> [String: CachedComment] {
        guard let pendingCommentIds = getPendingCommentIds() else {
            return [:]
        }

        let count = pendingCommentIds.count
        var pendingComments = Dictionary<String, CachedComment>()
        pendingComments.reserveCapacity(count)

        for i in 0..<count {
            let commentId = pendingCommentIds[i]
            let commentURL = cacheDirectory.appendingPathComponent(commentId)
            
            do {
                let data = try Data(contentsOf: commentURL)
                let cachedComment = try JSONDecoder().decode(CachedComment.self, from: data)
                pendingComments[commentId] = cachedComment
            } catch {
                print("Error retrieving cached comment \(commentId): \(error.localizedDescription)")
            }
        }

        return pendingComments
    }

    
    // Remove a comment from cache after successful upload
    func removeComment(withId commentId: String) {
        let commentURL = cacheDirectory.appendingPathComponent(commentId)
        
        do {
            try fileManager.removeItem(at: commentURL)
            removePendingCommentId(commentId)
        } catch {
            print("Error removing cached comment: \(error.localizedDescription)")
        }
    }
    
    // Save pending comment IDs to UserDefaults
    private func savePendingCommentId(_ commentId: String) {
        var pendingCommentIds = getPendingCommentIds() ?? []
        pendingCommentIds.append(commentId)
        UserDefaults.standard.set(pendingCommentIds, forKey: postQueueKey)
    }
    
    // Get list of pending post IDs from UserDefaults
    private func getPendingCommentIds() -> [String]? {
        return UserDefaults.standard.stringArray(forKey: postQueueKey)
    }
    
    // Remove a comment ID from the pending list
    private func removePendingCommentId(_ commentId: String) {
        guard var pendingCommentIds = getPendingCommentIds() else { return }
        pendingCommentIds.removeAll { $0 == commentId }
        UserDefaults.standard.set(pendingCommentIds, forKey: postQueueKey)
        print("Removed pending comment ID: \(commentId)")
    }
}
