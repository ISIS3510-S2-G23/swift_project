//
//  User.swift
//  swift_app
//
//  Created by Paulina Arrazola on 9/04/25.
//
import Foundation
import Firebase
import FirebaseAuth

struct AppUser: Identifiable, Codable {
    var id: String?
    var email: String?
    var username: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
    }
    
    // Add a converter from Firebase User
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email
        // Note: username would need to be fetched from Firestore or other source
        // as Firebase Auth doesn't store this information
    }
    
    // Empty initializer if needed
    init() {}
}
