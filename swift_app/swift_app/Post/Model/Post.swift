//
//  Post.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//
import Foundation
import Firebase

struct Post: Identifiable, Codable {
    var id: String?
    var asset: String?
    var comments: [String: String]?
    var tags: [String]?
    var text: String
    var timestamp: Date
    var title: String
    var upvotedBy: [String]?
    var upvotes: Int
    var user: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case asset
        case comments
        case tags
        case text
        case timestamp
        case title
        case upvotedBy
        case upvotes
        case user
    }
}
