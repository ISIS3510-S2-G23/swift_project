//
//  PostCardView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//
import SwiftUI

struct PostCardView: View {
    let post: Post
    let upvoteAction: () -> Void
    let conectado: Bool
    
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and tag
            HStack {
                Text(post.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let firstTag = post.tags?.first {
                    Text(firstTag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(getTagColor(for: firstTag))
                        .foregroundColor(.black.opacity(0.7))
                        .cornerRadius(12)
                }
            }
            
            // User
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
                Text(post.user)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Post content
            Text(post.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            // Image if available
            if let asset = post.asset, !asset.isEmpty {
                if conectado {
                    if let uiImage = image {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .foregroundColor(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(8)
                            .onAppear {
                                loadImage(from: asset)
                            }
                    }
                } else {
                    Text("No connection, image not available")
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                }
            }

            
            // Actions row
            HStack(spacing: 24) {
                Button(action: upvoteAction) {
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.green)
                        Text("\(post.upvotes)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.gray)
                    Text("\(post.comments?.count ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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

#Preview {
    PostCardView(
        post: Post(
            id: UUID().uuidString,
            asset: "https://res.cloudinary.com/dhrkcqd33/image/upload/v1745441946/image_gawkxi.jpg",
            comments: ["user1": "Great post!", "user2": "Very inspiring!"],
            tags: ["Recycling"],
            text: "Let’s reduce waste and build a more sustainable world with recycling and community action.",
            timestamp: Date(),
            title: "A Greener Future",
            upvotedBy: ["user1", "user2"],
            upvotes: 42,
            user: "EcoWarrior123"
        ),
        upvoteAction: {},
        conectado: false
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
