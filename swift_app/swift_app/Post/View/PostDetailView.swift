//
//  PostDetailView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Title
                Text(post.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Label(post.user, systemImage: "person.circle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(post.timestamp.formatted(date: .long, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Tags
                if let tags = post.tags {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(getTagColor(for: tag))
                                    .cornerRadius(12)
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                    }
                }
                
                // Image
                if let asset = post.asset, !asset.isEmpty {
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 250)
                            .cornerRadius(12)
                            .onAppear {
                                loadImage(from: asset)
                            }
                    }
                }

                // Text content
                Text(post.text)
                    .font(.body)
                    .foregroundColor(.primary)
                
                // Upvotes and comments
                HStack(spacing: 24) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text("\(post.upvotes) Upvotes")
                    }
                    
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .foregroundColor(.blue)
                        Text("\(post.comments?.count ?? 0) Comments")
                    }
                }
                .font(.subheadline)
                .padding(.top, 8)

                // Comment list
                if let comments = post.comments, !comments.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Comments")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(comments.sorted(by: { $0.key > $1.key }), id: \.key) { key, value in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(value)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Text(key)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString), !isLoading else { return }
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                }
            }
        }.resume()
    }
    
    private func getTagColor(for tag: String) -> Color {
        switch tag.lowercased() {
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
