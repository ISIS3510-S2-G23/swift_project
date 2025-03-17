//
//  ChallengePopUpView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct ChallengePopUpView: View {
    @Binding var isPresented: Bool // Controls visibility of popup
    let challenge: Challenge
        var body: some View {
            ZStack {
                // Dark overlay background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented = false
                    }

                // Popup content
                VStack(spacing: 15) {
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill") // SF Symbol
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.completedGreen) // Optional color
                    } else {
                        Image(.incompletedDonut) // Asset image
                            .resizable()
                            .frame(width: 80, height: 80)
                    }


                    if challenge.isCompleted{
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
                        
                        
                        Text("Your progess in this task is \(challenge.completionPercentage)% \n \n Go to the location of this callenge to complete it and earn the reward! \n\n \(challenge.reward)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                    }
                    

                    if challenge.isCompleted {
                        Button(action: {
                            // Claim action
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
                            // Claim action
                            isPresented = false
                        }) {
                            Text("Go to location")
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

#Preview {
    ChallengePopUpView(isPresented: .constant(true),challenge: Challenge(title: "Challenge 1 - go to 3 recycle points", completionPercentage: 100, isCompleted: true, expirationDate: "Feb 12", reward: "Money"))
}
