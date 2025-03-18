//
//  ChallengesViewModel.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import Foundation

class ChallengesViewModel: ObservableObject {
    @Published var challenges: [Challenge] = [
        Challenge(title: "Challenge 1 - go to 3 recycle points", completionPercentage: 100, isCompleted: true, expirationDate: "Feb 12", reward:"X", description: "Bottle"),
        Challenge(title: "Challenge 2 - recycle 6 plastic bottles in ECO", completionPercentage: 50, isCompleted: false, expirationDate: "Dec 25", reward:"X", description: "Bottle"),
        Challenge(title: "Challenge 3 - visit Propelplast S.A.S.", completionPercentage: 0, isCompleted: false, expirationDate: "Jun 23", reward:"X", description: "Bottle")
    ]
}
