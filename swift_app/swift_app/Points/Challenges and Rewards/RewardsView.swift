//
//  RewardsView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import SwiftUI

struct RewardsView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    var body: some View {
        Text("Rewards")
    }
}

#Preview {
    RewardsView()
}
