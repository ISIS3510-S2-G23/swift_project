//
//  swift_appApp.swift
//  swift_app
//
//  Created by Paulina Arrazola on 24/01/25.
//

import SwiftUI
import FirebaseCore
import FirebasePerformance

@main
struct swift_appApp: App {
    var body: some Scene {
        WindowGroup {
            WelcomeView1()
        }
        
    }
    init() {
          FirebaseApp.configure()
      }
}
