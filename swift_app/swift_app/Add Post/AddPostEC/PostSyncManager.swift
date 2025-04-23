//
//  PostSyncManager.swift
//  swift_app
//
//  Created by Paulina Arrazola on 23/04/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import FirebaseAuth
import FirebaseAnalytics

class PostSyncManager {
    static let shared = PostSyncManager()
    
    private let db = Firestore.firestore()
    private var isSyncing = false
    
    private init() {
        setupNetworkObserver()
    }
    
    private func setupNetworkObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkChange),
            name: .networkStatusChanged,
            object: nil
        )
    }
    
    @objc private func handleNetworkChange() {
        if NetworkMonitor.shared.isConnected && !isSyncing {
            syncPendingPosts()
        }
    }
    
    func syncPendingPosts() {
        guard NetworkMonitor.shared.isConnected else {
            print("Cannot sync posts: No internet connection")
            return
        }
        
        isSyncing = true
        
        let pendingPosts = PostCacheManager.shared.getPendingPosts()
        
        if pendingPosts.isEmpty {
            isSyncing = false
            return
        }
        
        print("Starting sync of \(pendingPosts.count) pending posts")
        
        let dispatchGroup = DispatchGroup()
        
        for (postId, cachedPost) in pendingPosts {
            dispatchGroup.enter()
            
            // Upload image if exists
            if let imageData = cachedPost.imageData, let image = UIImage(data: imageData) {
                uploadImageToCloudinary(image) { [weak self] cloudinaryUrl in
                    guard let self = self else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    self.fetchUsernameAndCreatePost(
                        userId: cachedPost.userId,
                        text: cachedPost.text,
                        timestamp: cachedPost.timestamp,
                        tags: cachedPost.tags,
                        assetUrl: cloudinaryUrl,
                        postId: postId,
                        completion: {
                            dispatchGroup.leave()
                        }
                    )
                }
            } else {
                fetchUsernameAndCreatePost(
                    userId: cachedPost.userId,
                    text: cachedPost.text,
                    timestamp: cachedPost.timestamp,
                    tags: cachedPost.tags,
                    assetUrl: nil,
                    postId: postId,
                    completion: {
                        dispatchGroup.leave()
                    }
                )
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isSyncing = false
            NotificationCenter.default.post(name: .pendingPostsSynced, object: nil)
        }
    }
    
    private func fetchUsernameAndCreatePost(userId: String, text: String, timestamp: Date, tags: [String], assetUrl: String?, postId: String, completion: @escaping () -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch username: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = snapshot?.data(), let username = data["username"] as? String else {
                print("User profile is incomplete.")
                completion()
                return
            }
            
            self.createFirestorePost(
                username: username,
                text: text,
                timestamp: timestamp,
                tags: tags,
                assetUrl: assetUrl,
                postId: postId,
                completion: completion
            )
        }
    }
    
    private func createFirestorePost(username: String, text: String, timestamp: Date, tags: [String], assetUrl: String?, postId: String, completion: @escaping () -> Void) {
        var postData: [String: Any] = [
            "text": text,
            "timestamp": Timestamp(date: timestamp),
            "user": username,
            "upvotedBy": [],
            "upvotes": 0
        ]
        
        if !tags.isEmpty {
            postData["tags"] = tags.map { $0.lowercased() }
        }
        
        if let assetUrl = assetUrl {
            postData["asset"] = assetUrl
        }
        
        db.collection("posts").addDocument(data: postData) { [weak self] error in
            guard self != nil else {
                completion()
                return
            }
            
            if let error = error {
                print("Error uploading pending post: \(error.localizedDescription)")
            } else {
                // Successfully uploaded, remove from cache
                PostCacheManager.shared.removePost(withId: postId)
                
                Analytics.logEvent("offline_post_synced", parameters: [
                    "has_image": assetUrl != nil
                ])
            }
            
            completion()
        }
    }
    
    private func uploadImageToCloudinary(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }
        
        let cloudName = "dhrkcqd33"
        let uploadPreset = "ecosphere"
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error uploading to Cloudinary: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    print("No data received from Cloudinary")
                    completion(nil)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let secureUrl = json["secure_url"] as? String {
                        completion(secureUrl)
                    } else {
                        print("Invalid response format from Cloudinary")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON response: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }.resume()
    }
}

extension Notification.Name {
    static let pendingPostsSynced = Notification.Name("pendingPostsSynced")
}
