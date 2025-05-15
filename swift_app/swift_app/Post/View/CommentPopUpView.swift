import SwiftUI

struct CommentPopupView: View {
    @Binding var isPresented: Bool
    @State private var commentText: String = ""
    let viewModel: ForumViewModel
    let post: Post

    var body: some View {
        VStack(spacing: 16) {
            if !viewModel.isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.orange)
                    Text("Offline Mode - Comments will be posted when connection is restored")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(8)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            Text("Leave your comment")
                .font(.headline)
            
            TextField("Write something...", text: $commentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                print("Adding comment to DB")
                viewModel.addComment(post: post, comment: commentText)
                print("Comment added to DB")
                isPresented = false
            }) {
                Text("Post comment")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ecoLightPurple)
                    .foregroundColor(.ecoMainPurple)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .overlay(
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(10)
            },
            alignment: .topTrailing
        )
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(32)
        
    }
}


