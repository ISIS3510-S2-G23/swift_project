//
//  Challenge.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/16/25.
//

import Foundation

struct Challenge: Identifiable {
    let id = UUID()
    
    //Challenge attributes (come from the challenges db)
    let title: String
    let expirationDate: Date
    let reward: String
    let description: String
    
    //User-Challenge attributes (userChallenge model)
    let complete_id: String
    let completionPercentage: Int
    let isCompleted: Bool
    
}
