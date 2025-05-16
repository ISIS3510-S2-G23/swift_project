//
//  ForumViewModel.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//
import Foundation
import Firebase
import Combine
import FirebaseAuth
import Network

class ForumViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var selectedFilter: String? = nil
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertTitle: String = "Post Comment"
    @Published var isPostSuccessful: Bool = false
    @Published var isPendingSync: Bool = false
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    private let networkMonitor = NWPathMonitor()
    @Published private(set) var isConnected = true
    
    init() {
        setupNetworkMonitoring()
        
        print("ESTADO CONEXION: \(isConnected)")
        
        Task {
            await manageCommentQueue()
        }
        
        fetchPosts()
    }
    
    
    
    
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = (path.status == .satisfied)
                if !wasConnected && self?.isConnected == true {
                    print("Network reconnected, refreshing data...")
                    self?.fetchPosts()
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
    
    func fetchPosts() {
        // Remove any existing listener
        listenerRegistration?.remove()
        
        // Add a real-time listener to the posts collection
        listenerRegistration = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting posts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No posts found")
                    return
                }
                
                self.posts = documents.compactMap { document -> Post? in
                    let data = document.data()
                    
                    // Manual decoding without try-catch since we're not throwing errors
                    let id = document.documentID
                    let asset = data["asset"] as? String
                    let comments = data["comments"] as? [String: String]
                    let tags = data["tags"] as? [String]
                    let text = data["text"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let title = data["title"] as? String ?? ""
                    let upvotedBy = data["upvotedBy"] as? [String]
                    let upvotes = data["upvotes"] as? Int ?? 0
                    let user = data["user"] as? String ?? ""
                    
                    return Post(
                        id: id,
                        asset: asset,
                        comments: comments,
                        tags: tags,
                        text: text,
                        timestamp: timestamp,
                        title: title,
                        upvotedBy: upvotedBy,
                        upvotes: upvotes,
                        user: user
                    )
                
                }
                
                self.applyFilter()
            }
    }
    
    func applyFilter() {
        if let filter = selectedFilter, !filter.isEmpty {
            filteredPosts = posts.filter { post in
                post.tags?.contains(filter.lowercased()) ?? false
            }
        } else {
            filteredPosts = posts
        }
    }
    
    func setFilter(_ filter: String?) {
        selectedFilter = filter
        applyFilter()
    }
    
    func addComment(post: Post, comment: String) {
        guard let postId = post.id else { return }
        
        print("UPDATING COMMENT - id \(postId)")
        let userId = Auth.auth().currentUser?.displayName ?? "anonymous"
        print("UPDATING COMMENT - user \(userId)")
        // Ensure comments is [String: String]
        let comments = post.comments ?? [:]
    
        // Create a new dictionary by merging
        let updatedComments = comments.merging([userId: comment]) { (_, new) in new }
        
        //Manage in case of no network connectivity
        if isConnected {
            addCommentToDB(postId: postId, updatedComments: updatedComments)
        }
        else {
            let commentId = CommentCacheManager.shared.cacheComment(pPostId: postId, pUpdatedComments: updatedComments)
            
            if !commentId.isEmpty {
                alertTitle = "Offline Mode"
                alertMessage = "Your comment has been saved and will be uploaded when you're back online."
                isPostSuccessful = true
                isPendingSync = true
                
                
            } else {
                alertTitle = "Error"
                alertMessage = "Failed to save your comment. Please try again."
                isPostSuccessful = false
            }
        }
    }
    
    func manageCommentQueue() async {
        //Check if there are any pending comments
        let pendingComments = CommentCacheManager.shared.getPendingComments()
        
        //If there are any pending comments, upload them to the DB
        if pendingComments.isEmpty {
            print("No pending comments to upload")
            return
        }
        else {
            print("Adding pending comments")
            for (commentId, cachedComment) in pendingComments {
                print("Adding comment \(commentId)")
                addCommentToDB(postId: cachedComment.postId, updatedComments: cachedComment.updatedComments)
                CommentCacheManager.shared.removeComment(withId: commentId)
            }
        }
    }
    
    func addCommentToDB(postId: String, updatedComments: [String: String]) {
        print("UPDATING COMMENT - comments \(updatedComments)")
        // Safely pass to Firestore
        db.collection("posts").document(postId).updateData([
            "comments": updatedComments
        ])
        print("UPDATING COMMENT - UPDATED")
    }

    
    func upvotePost(_ post: Post) {
        guard let postId = post.id else { return }
        
        // For simplicity, assuming current user's ID is available
        let userId = Auth.auth().currentUser?.uid ?? "anonymous"
        
        // Check if user already upvoted
        var upvotedBy = post.upvotedBy ?? []
        
        if upvotedBy.contains(userId) {
            // User already upvoted, remove upvote
            upvotedBy.removeAll { $0 == userId }
            db.collection("posts").document(postId).updateData([
                "upvotedBy": upvotedBy,
                "upvotes": post.upvotes - 1
            ])
        } else {
            // Add upvote
            upvotedBy.append(userId)
            db.collection("posts").document(postId).updateData([
                "upvotedBy": upvotedBy,
                "upvotes": post.upvotes + 1
            ])
        }
    }
    
    deinit {
        networkMonitor.cancel()
        listenerRegistration?.remove()
    }
}
