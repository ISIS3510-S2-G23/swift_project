//
//  ChallengePopUpView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct RewardPopUpView: View {
    @Binding var isPresented: Bool
    let challenge: Challenge
    @Binding var selectedTab: String

    var body: some View {
        ZStack {
            // Dark overlay background
            Color.black.opacity(0)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }

            // Popup content
            VStack(spacing: 15) {
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.completedGreen)
                } else {
                    Image(.incompletedDonut)
                        .resizable()
                        .frame(width: 80, height: 80)
                }

                if challenge.isCompleted {
                    Text("You finished the challenge!")
                        .font(.headline)
                        .foregroundColor(.completedGreen)

                    Text("You can claim your reward\n\n \(challenge.reward)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    Text("You haven't completed this challenge!")
                        .font(.headline)
                        .foregroundColor(.ecoMainPurple)

                    Text("Go to the challenges in this point and complete this challenge to claim your reward")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }

                if challenge.isCompleted {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Claim")
                            .foregroundColor(.ecoMainPurple)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 10)
                            .background(.completedButtonGreen)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        isPresented = false
                        selectedTab = "Challenges"
                    }) {
                        Text("Go to challenge")
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 10)
                            .background(.ecoMainPurple)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(7)
            .frame(width: 320, height: 330)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .overlay(
                // Close button
                Button(action: {
                    isPresented = false
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
}
