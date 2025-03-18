//
//  Challenge.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import Foundation

struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let completionPercentage: Int
    let isCompleted: Bool
    let expirationDate: String
    let reward: String
    let description: String
}
