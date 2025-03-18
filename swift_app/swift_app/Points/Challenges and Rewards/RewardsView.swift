//
//  RewardsView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct RewardsView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @Binding var selectedTab: String
    
    @State private var selectedChallenge: Challenge?
    
    var body: some View {
        ZStack{
            VStack{
                ForEach(viewModel.challenges){
                    challenge in RewardCardView(challenge: challenge, selectedChallenge: $selectedChallenge)
                }
            }
            .padding(.top, 10)
            
            if let challenge = selectedChallenge {
                RewardPopUpView(
                    isPresented:Binding(
                        get: { selectedChallenge != nil },
                        set: { if !$0 { selectedChallenge = nil } }
                    ),
                    challenge: challenge,
                    selectedTab: $selectedTab
                )
            }
        }
    }
}

#Preview {
    RewardsView(selectedTab: .constant("Rewards"))
}
