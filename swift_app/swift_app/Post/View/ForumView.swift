//
//  ForumView.swift.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//
import SwiftUI
import FirebaseAnalytics

struct ForumView: View {
    @StateObject private var viewModel = ForumViewModel()
    @State private var searchText = ""
    @Binding var selectedView: Int
    
    private let topics = ["Recycling", "Upcycling", "Transport"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Find topics", text: $searchText)
                    .foregroundColor(.primary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(20)
            .padding(.horizontal)
            
            // Topics filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(topics, id: \.self) { topic in
                        TopicFilterButton(
                            topic: topic,
                            isSelected: viewModel.selectedFilter == topic.lowercased(),
                            action: {
                                if viewModel.selectedFilter == topic.lowercased() {
                                    viewModel.setFilter(nil)
                                } else {
                                    viewModel.setFilter(topic.lowercased())
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            
            if !viewModel.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.orange)
                    Text("Offline Mode - Some posts may not be available")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            if viewModel.filteredPosts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "tray")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No posts available")
                        .font(.headline)
                    if !viewModel.isConnected {
                        Text("Connect to the internet to see all posts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxHeight: .infinity)
            } else {
                // Posts list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPosts) { post in
                            NavigationLink(destination: PostDetailView(post: post)) {
                                PostCardView(
                                    post: post,
                                    upvoteAction: { viewModel.upvotePost(post) }, conectado: viewModel.isConnected
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
           
        }
        .onAppear {
            logScreen("ForumView")
        }
    }
    
    // Filter posts based on search text and selected topic
    private var filteredPosts: [Post] {
        if searchText.isEmpty {
            return viewModel.filteredPosts
        } else {
            return viewModel.filteredPosts.filter { post in
                post.title.localizedCaseInsensitiveContains(searchText) ||
                post.text.localizedCaseInsensitiveContains(searchText) ||
                (post.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
            }
        }
    }

  
    func logScreen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: name
        ])
    }
}


struct TopicFilterButton: View {
    let topic: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: getIconName(for: topic))
                Text(topic)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(getBackgroundColor(for: topic))
            .foregroundColor(.black.opacity(0.7))
            .cornerRadius(16)
        }
    }
    
    private func getIconName(for topic: String) -> String {
        switch topic.lowercased() {
        case "recycling":
            return "arrow.3.trianglepath"
        case "upcycling":
            return "arrow.up.circle"
        case "transport":
            return "car.fill"
        default:
            return "tag"
        }
    }
    
    private func getBackgroundColor(for topic: String) -> Color {
        switch topic.lowercased() {
        case "recycling":
            return Color.green.opacity(0.3)
        case "upcycling":
            return Color.blue.opacity(0.3)
        case "transport":
            return Color.pink.opacity(0.3)
        default:
            return Color.gray.opacity(0.3)
        }
    }
}
