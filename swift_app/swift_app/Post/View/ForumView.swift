//
//  ForumView.swift.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//
import SwiftUI

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
            
            // Posts list
            ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPosts) { post in
                                NavigationLink(destination: PostDetailView(post: post)) {
                                    PostCardView(
                                        post: post,
                                        upvoteAction: { viewModel.upvotePost(post) }
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
