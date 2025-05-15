import SwiftUI

struct CommentPopupView: View {
    @Binding var isPresented: Bool
    @State private var commentText: String = ""
    

    var body: some View {
        VStack(spacing: 16) {
            Text("Leave your comment")
                .font(.headline)
            
            TextField("Write something...", text: $commentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                
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

#Preview {
    // Using a constant Binding to simulate a visible popup
    CommentPopupView(
        isPresented: .constant(true),
        
    )
    .background(Color.gray.opacity(0.3))
}
