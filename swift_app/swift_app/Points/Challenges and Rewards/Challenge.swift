//
//  Challenge.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//
import Foundation

// Model for the Challenge object in the app
struct Challenge: Identifiable, Codable {
    let id = UUID()
    
    // Challenge attributes (come from the challenges db)
    let title: String
    let expirationDate: Date
    let reward: String
    let description: String
    
    // User-Challenge attributes (userChallenge model)
    let complete_id: String
    let completionPercentage: Int
    let isCompleted: Bool
    
    // CodingKeys to explicitly specify which properties to encode/decode
    enum CodingKeys: String, CodingKey {
        case title
        case expirationDate
        case reward
        case description
        case complete_id
        case completionPercentage
        case isCompleted
        // Note: We don't include id as it's generated locally and not stored
    }
}
