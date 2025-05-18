//
//  AddPostViewModel.swift
//  swift_app
//
//  Created by Paulina Arrazola on 13/04/25.
//
import Foundation
import Firebase
import FirebaseFirestore
import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseAnalytics

class AddPostViewModel: ObservableObject {
    @Published var postContent: String = ""
    @Published var selectedImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertTitle: String = "Forum Post"
    @Published var isPostSuccessful: Bool = false
    @Published var selectedCategories: [String] = []
    @Published var isPendingSync: Bool = false
    
    // Caption generation properties
    @Published var isGeneratingCaption: Bool = false
    @Published var suggestedCaption: String?
    @Published var isShowingCaptionSuggestion: Bool = false
    
    private var db = Firestore.firestore()
    private let captionService = CaptionGeneratorService()
    
    init() {
        // Register for network status change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkPendingPosts),
            name: .pendingPostsSynced,
            object: nil
        )
    }
    
    @objc func checkPendingPosts() {
        DispatchQueue.main.async {
            let pendingPosts = PostCacheManager.shared.getPendingPosts()
            self.isPendingSync = !pendingPosts.isEmpty
        }
    }
    
    func generateCaption() {
        guard let image = selectedImage else {
            alertTitle = "Caption Error"
            alertMessage = "No image selected to generate caption for."
            isShowingCaptionSuggestion = false
            showAlert = true
            return
        }
        
        // Check network connectivity
        guard AddPostNetworkMonitor.shared.isConnected else {
            alertTitle = "No Internet Connection"
            alertMessage = "Caption suggestion requires an internet connection. This feature will be available when your connection resumes."
            isShowingCaptionSuggestion = false
            showAlert = true
            return
        }
        
        isGeneratingCaption = true
        
        Task {
            do {
                let caption = try await captionService.generateCaption(for: image)
                
                await MainActor.run {
                    self.isGeneratingCaption = false
                    self.suggestedCaption = caption
                    self.alertTitle = "Caption Suggestion"
                    self.alertMessage = "Suggested caption: \"\(caption)\"\n\nWould you like to use this caption?"
                    self.isShowingCaptionSuggestion = true
                    self.showAlert = true
                    
                    // Track caption generation
                    Analytics.logEvent("caption_generated", parameters: [
                        "success": true
                    ])
                }
            } catch {
                await MainActor.run {
                    self.isGeneratingCaption = false
                    self.alertTitle = "Caption Error"
                    self.alertMessage = "Failed to generate caption: \(error.localizedDescription)"
                    self.isShowingCaptionSuggestion = false
                    self.showAlert = true
                    
                    // Track caption generation failure
                    Analytics.logEvent("caption_generated", parameters: [
                        "success": false,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    func validatePost() -> Bool {
        if postContent.isEmpty {
            alertTitle = "Forum Post"
            alertMessage = "Please write something before posting."
            showAlert = true
            return false
        }
        return true
    }
    
    func submitPost() {
        if !validatePost() {
            return
        }
        
        isLoading = true
        
        guard let userId = Auth.auth().currentUser?.uid else {
            alertTitle = "Forum Post"
            alertMessage = "Please log in to post."
            showAlert = true
            isLoading = false
            return
        }
        
        // Check network connectivity
        if AddPostNetworkMonitor.shared.isConnected {
            // If online, proceed with normal post flow
            if let image = selectedImage {
                uploadImageToCloudinary(image) { [weak self] cloudinaryUrl in
                    guard let self = self else { return }
                    
                    if let cloudinaryUrl = cloudinaryUrl {
                        self.fetchUsernameAndCreatePost(userId: userId, assetUrl: cloudinaryUrl)
                    } else {
                        self.isLoading = false
                        self.alertTitle = "Forum Post"
                        self.alertMessage = "Failed to upload image. Please try again."
                        self.showAlert = true
                    }
                }
            } else {
                fetchUsernameAndCreatePost(userId: userId, assetUrl: nil)
            }
        } else {
            // If offline, cache the post for later upload
            savePostToCache(userId: userId)
        }
    }
    
    private func savePostToCache(userId: String) {
        let postId = PostCacheManager.shared.cachePost(
            text: postContent,
            timestamp: Date(),
            tags: selectedCategories,
            image: selectedImage,
            userId: userId
        )
        
        isLoading = false
        
        if !postId.isEmpty {
            alertTitle = "Offline Mode"
            alertMessage = "Your post has been saved and will be uploaded when you're back online."
            isPostSuccessful = true
            isPendingSync = true
            
            // Track offline post creation
            Analytics.logEvent("offline_post_created", parameters: [
                "has_image": selectedImage != nil
            ])
            
            resetForm()
        } else {
            alertTitle = "Error"
            alertMessage = "Failed to save your post. Please try again."
            isPostSuccessful = false
        }
        
        showAlert = true
    }
    
    private func fetchUsernameAndCreatePost(userId: String, assetUrl: String?) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to fetch username: \(error.localizedDescription)")
                self.alertTitle = "Forum Post"
                self.alertMessage = "Error fetching user information."
                self.showAlert = true
                self.isLoading = false
                return
            }
            
            guard let data = snapshot?.data(), let username = data["username"] as? String else {
                self.alertTitle = "Forum Post"
                self.alertMessage = "User profile is incomplete."
                self.showAlert = true
                self.isLoading = false
                return
            }
            
            self.createFirestorePost(username: username, assetUrl: assetUrl)
        }
    }
    
    private func createFirestorePost(username: String, assetUrl: String?) {
        var postData: [String: Any] = [
            "text": postContent,
            "timestamp": Timestamp(),
            "user": username,
            "upvotedBy": [],
            "upvotes": 0
        ]
        
        if !selectedCategories.isEmpty {
            postData["tags"] = selectedCategories.map { $0.lowercased() }
        }
        
        if let assetUrl = assetUrl {
            postData["asset"] = assetUrl
        }
        
        db.collection("posts").addDocument(data: postData) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.alertTitle = "Error"
                self.alertMessage = "Error: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertTitle = "Forum Post"
                self.alertMessage = "Post submitted successfully!"
                self.showAlert = true
                self.isPostSuccessful = true
                
                Analytics.logEvent("post_created", parameters: [
                    "has_tags": !self.selectedCategories.isEmpty
                ])
                
                // Reset form
                self.resetForm()
            }
        }
    }
    
    private func resetForm() {
        postContent = ""
        selectedImage = nil
        selectedCategories = []
        suggestedCaption = nil
        isShowingCaptionSuggestion = false
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
        
        self.isLoading = true
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard self != nil else { return }
                
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
