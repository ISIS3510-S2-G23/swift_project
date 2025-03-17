//
//  ChallengesView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.challenges) { challenge in
                ChallengeCardView(challenge: challenge)
            }
        }
        .padding(.top, 10)
    }
}

#Preview {
    ChallengesView()
}
