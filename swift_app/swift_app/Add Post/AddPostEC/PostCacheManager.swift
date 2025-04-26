//
//  PostCacheManager.swift
//  swift_app
//
//  Created by Paulina Arrazola on 23/04/25.
//

import Foundation
import UIKit

struct CachedPost: Codable {
    let text: String
    let timestamp: Date
    let tags: [String]
    let imageData: Data?
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case text, timestamp, tags, imageData, userId
    }
}

class PostCacheManager {
    static let shared = PostCacheManager()
    
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let postQueueKey = "pendingPosts"
    
    private init() {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("PendingPosts")
        
        do {
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("Error creating cache directory: \(error.localizedDescription)")
        }
    }
    
    // Save post to persistent cache
    func cachePost(text: String, timestamp: Date, tags: [String], image: UIImage?, userId: String) -> String {
        let postId = UUID().uuidString
        let imageData = image?.jpegData(compressionQuality: 0.7)
        
        let cachedPost = CachedPost(
            text: text,
            timestamp: timestamp,
            tags: tags,
            imageData: imageData,
            userId: userId
        )
        
        do {
            let data = try JSONEncoder().encode(cachedPost)
            try data.write(to: cacheDirectory.appendingPathComponent(postId))
            savePendingPostId(postId)
            return postId
        } catch {
            print("Error caching post: \(error.localizedDescription)")
            return ""
        }
    }
    
    // Get all pending posts that need to be uploaded
    func getPendingPosts() -> [String: CachedPost] {
        var pendingPosts = [String: CachedPost]()
        
        guard let pendingPostIds = getPendingPostIds() else {
            return pendingPosts
        }
        
        for postId in pendingPostIds {
            let postURL = cacheDirectory.appendingPathComponent(postId)
            
            do {
                let data = try Data(contentsOf: postURL)
                let cachedPost = try JSONDecoder().decode(CachedPost.self, from: data)
                pendingPosts[postId] = cachedPost
            } catch {
                print("Error retrieving cached post \(postId): \(error.localizedDescription)")
            }
        }
        
        return pendingPosts
    }
    
    // Remove a post from cache after successful upload
    func removePost(withId postId: String) {
        let postURL = cacheDirectory.appendingPathComponent(postId)
        
        do {
            try fileManager.removeItem(at: postURL)
            removePendingPostId(postId)
        } catch {
            print("Error removing cached post: \(error.localizedDescription)")
        }
    }
    
    // Save pending post IDs to UserDefaults
    private func savePendingPostId(_ postId: String) {
        var pendingPostIds = getPendingPostIds() ?? []
        pendingPostIds.append(postId)
        UserDefaults.standard.set(pendingPostIds, forKey: postQueueKey)
    }
    
    // Get list of pending post IDs from UserDefaults
    private func getPendingPostIds() -> [String]? {
        return UserDefaults.standard.stringArray(forKey: postQueueKey)
    }
    
    // Remove a post ID from the pending list
    private func removePendingPostId(_ postId: String) {
        guard var pendingPostIds = getPendingPostIds() else { return }
        pendingPostIds.removeAll { $0 == postId }
        UserDefaults.standard.set(pendingPostIds, forKey: postQueueKey)
    }
}
