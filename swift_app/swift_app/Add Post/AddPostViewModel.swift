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

class AddPostViewModel: ObservableObject {
    @Published var postContent: String = ""
    @Published var category: String = ""
    @Published var selectedImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isPostSuccessful: Bool = false
    @Published var selectedCategories: [String] = []

    private var db = Firestore.firestore()

    func validatePost() -> Bool {
        if postContent.isEmpty {
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

        // Get current user ID from Firebase Auth
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "Please log in to post."
            showAlert = true
            isLoading = false
            return
        }

        if let image = selectedImage {
            uploadImageToCloudinary(image) { [weak self] cloudinaryUrl in
                guard let self = self else { return }

                if let cloudinaryUrl = cloudinaryUrl {
                    self.fetchUsernameAndCreatePost(userId: userId, assetUrl: cloudinaryUrl)
                } else {
                    self.isLoading = false
                    self.alertMessage = "Failed to upload image. Please try again."
                    self.showAlert = true
                }
            }
        } else {
            fetchUsernameAndCreatePost(userId: userId, assetUrl: nil)
        }
    }

    private func fetchUsernameAndCreatePost(userId: String, assetUrl: String?) {
        let userRef = db.collection("users").document(userId)

        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to fetch username: \(error.localizedDescription)")
                self.alertMessage = "Error fetching user information."
                self.showAlert = true
                self.isLoading = false
                return
            }

            guard let data = snapshot?.data(), let username = data["username"] as? String else {
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

        if !category.isEmpty {
            postData["tags"] = [category.lowercased()]
        }

        if let assetUrl = assetUrl {
            postData["asset"] = assetUrl
        }

        db.collection("posts").addDocument(data: postData) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.alertMessage = "Error: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertMessage = "Post submitted successfully!"
                self.showAlert = true
                self.isPostSuccessful = true

                // Reset form
                self.postContent = ""
                self.selectedImage = nil
                self.category = ""
            }
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
}
