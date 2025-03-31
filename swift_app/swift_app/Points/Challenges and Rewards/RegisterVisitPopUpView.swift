import SwiftUI
import UIKit

struct RegisterVisitPopUpView: View {
    @Binding var isPresented2: Bool
    let challenge: Challenge
    @Binding var selectedTab: String
    @State private var inputText: String = ""
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    // Add viewModel
    let viewModel: ChallengesViewModel
    @StateObject private var cameraLogic = CameraLogic()

    var body: some View {
        ZStack {
                    Color.black.opacity(0)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isPresented2 = false
                        }

            VStack(spacing: 15) {
                Text("Register visit")
                    .font(.headline)
                    .foregroundColor(.ecoMainPurple)

                Text("Validate your challenge with a photo of \(challenge.description)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                // Button to Open Camera
                Button(action: {
                                    showCamera = true
                                }) {
                                    Text("Open Camera")
                                        .foregroundColor(.ecoMainPurple)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(.ecoLightPurple)
                                        .cornerRadius(15)
                                }
                                .sheet(isPresented: $showCamera) {
                                    ImagePicker(isPresented: $showCamera, selectedImage: $capturedImage)
                                }
                                // Updated onChange to use new syntax
                                .onChange(of: capturedImage) { _, newImage in
                                    cameraLogic.capturedImage = newImage
                                }

                // Image Analysis Section
                if capturedImage != nil {
                    Button(action: {
                        cameraLogic.analyzeImage(challengeDescription: challenge.description)
                    }) {
                        Text("Analyze Image")
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ecoMainPurple)
                            .cornerRadius(15)
                    }
                }

                // Show analysis result or loading
                if cameraLogic.isAnalyzing {
                    ProgressView()
                } else if let analysisResult = cameraLogic.analysisResult {
                    ScrollView {
                        Text("Analysis Result:")
                            .font(.headline)
                        Text(analysisResult)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .frame(maxHeight: 100)
                } else if let errorMessage = cameraLogic.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }

                Text("Provide the code given by the recycle point manager")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                TextField("Type code", text: $inputText)
                    .padding(15)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .padding(.horizontal, 15)
                    .foregroundStyle(.gray)

                Button(action: {
                    viewModel.updateProgressChallenge(pChallenge: challenge, newProgress: 100)
                    isPresented2 = false
                }) {
                    Text("Register")
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 10)
                        .background(.ecoMainPurple)
                        .cornerRadius(10)
                }
            }
        }
        .padding(7)
        .frame(width: 320, height: 450)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            Button(action: {
                isPresented2 = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .padding(10)
            }
            .position(x: 280, y: 20),
            alignment: .topTrailing
        )
    }
}
