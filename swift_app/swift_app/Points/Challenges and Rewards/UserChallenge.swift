//
//  UserChallenge.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/18/25.
//
import Foundation

struct UserChallenge: Identifiable {
    let id = UUID()
    let complete_id: String
    let progress: Double
    let isCompleted: Bool
}
