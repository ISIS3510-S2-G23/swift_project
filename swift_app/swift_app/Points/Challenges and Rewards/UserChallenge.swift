//
//  UserChallenge.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/18/25.
//
import Foundation

//Class for managing user-challenge records in the data base. Not used explicitly anywhere else in the app
struct UserChallenge: Identifiable {
    let id = UUID()
    let complete_id: String
    let progress: Double
    let isCompleted: Bool
}
