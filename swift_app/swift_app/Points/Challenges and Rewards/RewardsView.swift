//
//  RewardsView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI
import FirebaseAnalytics

struct RewardsView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @Binding var selectedTab: String
    
    @State private var selectedChallenge: Challenge?
    
    var body: some View {
        ZStack{
            VStack{
                
                // Network status indicator
                if !viewModel.isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.orange)
                        Text("Offline Mode - Showing rewards for challenges that are not completed yet")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                if viewModel.challenges.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No rewards available")
                            .font(.headline)
                        if !viewModel.isConnected {
                            Text("Connect to the internet to see all rewards")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    ForEach(viewModel.challenges){
                        challenge in RewardCardView(challenge: challenge, selectedChallenge: $selectedChallenge)
                    }
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
        .onAppear { 
            logScreen("RewardsView")
        }
    }


    func logScreen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: name
        ])
    }
}

#Preview {
    RewardsView(selectedTab: .constant("Rewards"))
}
