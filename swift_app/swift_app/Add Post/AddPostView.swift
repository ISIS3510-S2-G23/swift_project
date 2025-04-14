//
//  AddPostView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/17/25.
//
import SwiftUI
import Firebase
import UIKit

struct AddPostView: View {
    @Binding var selectedView: Int
    @StateObject private var viewModel = AddPostViewModel()
    @State private var showImagePicker = false
    @State private var showCategoryPicker = false

    private let categories = ["Upcycle", "Transport", "Recycling", "Sustainability"]

    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }

            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("What are you thinking today for forum 1?")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.top)

                    ZStack(alignment: .topLeading) {
                        if viewModel.postContent.isEmpty {
                            Text("Share your thoughts")
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(8)
                        }

                        TextEditor(text: $viewModel.postContent)
                            .padding(8)
                            .background(Color.clear)
                            .opacity(viewModel.postContent.isEmpty ? 0.3 : 1)
                    }
                    .frame(minHeight: 200)
                    .background(Color.white)
                    .cornerRadius(8)

                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    }

                    HStack {
                        Button(action: {
                            showCategoryPicker.toggle()
                        }) {
                            Text("Add category +")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "camera")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }

                    // Selected Tags
                    if !viewModel.selectedCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.selectedCategories, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                        .onTapGesture {
                                            viewModel.selectedCategories.removeAll { $0 == tag }
                                        }
                                }
                            }
                        }
                    }

                    // Post button image
                    Button(action: {
                        viewModel.submitPost()
                    }) {
                        Image("Post")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding()
                .background(Color("CardBackground"))
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(isPresented: $showImagePicker, selectedImage: $viewModel.selectedImage)
        }
        .sheet(isPresented: $showCategoryPicker) {
            NavigationView {
                List {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            if !viewModel.selectedCategories.contains(category) {
                                viewModel.selectedCategories.append(category)
                            }
                            showCategoryPicker = false
                        }) {
                            HStack {
                                Text(category)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Select tags")
                .navigationBarItems(trailing: Button("Cancel") {
                    showCategoryPicker = false
                })
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Forum Post"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    if viewModel.isPostSuccessful {
                        // You could dismiss the view here if needed
                    }
                }
            )
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
