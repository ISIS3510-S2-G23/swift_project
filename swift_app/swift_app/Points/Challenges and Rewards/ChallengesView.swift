//
//  ChallengesView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @State private var isPopupPresented = false  // Tracks if the popup is shown
    @State private var selectedChallenge: Challenge?  // Stores the selected challenge

    var body: some View {
        ZStack {
            VStack {
                ForEach(viewModel.challenges) { challenge in
                    ChallengeCardView(
                        challenge: challenge,
                        isPopupPresented: $isPopupPresented,
                        selectedChallenge: $selectedChallenge
                    )
                }
            }
            .padding(.top, 10)

            // Show popup if a challenge is selected
            if isPopupPresented, let challenge = selectedChallenge {
                ChallengePopUpView(isPresented: $isPopupPresented, challenge: challenge)
                    .zIndex(1)  // Ensure it appears above everything
            }
        }
    }
}

#Preview {
    ChallengesView()
}
