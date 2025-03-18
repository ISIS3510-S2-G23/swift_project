//
//  ChallengesView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @Binding var selectedTab: String

    @State private var selectedChallenge: Challenge?
    @State private var selectedChallenge2: Challenge?

    var body: some View {
        ZStack {
            VStack {
                ForEach(viewModel.challenges) { challenge in
                    ChallengeCardView(challenge: challenge, selectedChallenge: $selectedChallenge, selectedChallenge2: $selectedChallenge2)
                }
            }
            .padding(.top, 10)

            
            if let challenge = selectedChallenge {
                ChallengePopUpView(
                    isPresented: Binding(
                        get: { selectedChallenge != nil },
                        set: { if !$0 { selectedChallenge = nil } }
                    ),
                    challenge: challenge,
                    selectedTab: $selectedTab 
                )
            }
            
            if let challenge = selectedChallenge2 {
                RegisterVisitPopUpView(
                    isPresented2: Binding(
                        get: { selectedChallenge2 != nil },
                        set: { if !$0 { selectedChallenge2 = nil } }
                    ),
                    challenge: challenge,
                    selectedTab: $selectedTab
                )
            }
            
            
        }
    }
}

#Preview {
    ChallengesView(selectedTab: .constant("Challenges"))
}
