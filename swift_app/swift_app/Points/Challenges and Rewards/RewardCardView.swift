//
//  ChallengeCardView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct RewardCardView: View {
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

                Text(challenge.isCompleted ? "Already clamied": "Ends \(challenge.expirationDate)")
                    .font(.footnote)
                    .foregroundColor(.gray)
               
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
