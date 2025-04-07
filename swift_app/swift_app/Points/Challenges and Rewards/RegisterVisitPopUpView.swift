import SwiftUI
import UIKit

struct RegisterVisitPopUpView: View {
    @Binding var isPresented2: Bool
    let challenge: Challenge
    @Binding var selectedTab: String
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var feedbackMessage: String?
    @State private var isSuccess: Bool = false

    let viewModel: ChallengesViewModel
    @StateObject private var cameraLogic = CameraLogic()

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented2 = false
                }

            VStack {
                Spacer() // Push content down

                VStack(spacing: 15) {
                    Text("Validate your challenge with a photo of \(challenge.description)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Button(action: {
                        showCamera = true
                    }) {
                        Text("Open Camera")
                            .foregroundColor(.ecoMainPurple)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.ecoLightPurple)
                            .cornerRadius(15)
                    }
                    .sheet(isPresented: $showCamera) {
                        ImagePicker(isPresented: $showCamera, selectedImage: $capturedImage)
                    }
                    .onChange(of: capturedImage) { _, newImage in
                        cameraLogic.capturedImage = newImage
                    }

                    if capturedImage != nil {
                        Button(action: {
                            cameraLogic.analyzeImage(
                                challengeDescription: challenge.description,
                                onPositiveMatch: {
                                    viewModel.updateProgressChallenge(pChallenge: challenge, newProgress: 100)
                                    feedbackMessage = "Challenge completed successfully!"
                                    isSuccess = true

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isPresented2 = false
                                    }
                                },
                                onNegativeMatch: { response in
                                    feedbackMessage = "Challenge not validated: \(response)"
                                    isSuccess = false
                                }
                            )
                        }) {
                            Text("Analyze Image")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.ecoMainPurple)
                                .cornerRadius(15)
                        }
                    }

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
                    }
                }

                Spacer() // Push content up
            }
            .padding(20)
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
                },
                alignment: .topTrailing
            )

            }
        }
    }

