import SwiftUI
import FirebaseAnalytics

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @Binding var selectedTab: String

    @State private var selectedChallenge: Challenge?
    @State private var selectedChallenge2: Challenge?

    var body: some View {
        ZStack {
            VStack {
                // Network status indicator
                if !viewModel.isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.orange)
                        Text("Offline Mode - Showing challenges that are not completed yet")
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
                        Text("No challenges available")
                            .font(.headline)
                        if !viewModel.isConnected {
                            Text("Connect to the internet to see all challenges")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack {
                            ForEach(viewModel.challenges) { challenge in
                                ChallengeCardView(
                                    challenge: challenge,
                                    selectedChallenge: $selectedChallenge,
                                    selectedChallenge2: $selectedChallenge2
                                )
                            }
                        }
                        .padding(.top, 10)
                    }
                }
            }

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
                    selectedTab: $selectedTab,
                    viewModel: viewModel
                )
            }
        }
        .onAppear {
            logScreen("ChallengesView")
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
    ChallengesView(selectedTab: .constant("Challenges"))
}
