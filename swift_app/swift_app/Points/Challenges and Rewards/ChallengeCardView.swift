//
//  ChallengeCardView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    @Binding var selectedChallenge: Challenge?

    var body: some View {
        HStack {
            Button(action: {
                selectedChallenge = challenge  
            }) {
                Image(challenge.isCompleted ? .completeChallenge : .incompleteChallenge)
                    .resizable()
                    .frame(width: 55, height: 55)
                    .padding(.leading, 15)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.title)
                    .font(.footnote)
                    .foregroundColor(.ecoMainPurple)

                HStack {
                    Text("\(challenge.completionPercentage)% completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 17)
                    Spacer()
                    if !challenge.isCompleted {
                        Button(action: {
                            // Action for registering visit
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                Text("Register visit")
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.ecoMainPurple)
                            .cornerRadius(10)
                        }
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                    }
                }
            }
            .padding(.leading, 5)

            Spacer()
        }
        .frame(width: 375, height: 90)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.bottom, 20)
    }
}
