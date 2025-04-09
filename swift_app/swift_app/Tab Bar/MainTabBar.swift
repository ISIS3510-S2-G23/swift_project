//
//  MainTabView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/17/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedView: Int = 1  // Default tab (Points)

    var body: some View {
        VStack(spacing: 0) {
            // Display the selected view
            ZStack {
                switch selectedView {
                case 0:
                    ForumView(selectedView: $selectedView)
                case 1:
                    PointsView(selectedView: $selectedView)
                case 2:
                    AddPostView(selectedView: $selectedView)
                case 3:
                    NotificationsView(selectedView: $selectedView)
                case 4:
                    AccountView(selectedView: $selectedView)
                default:
                    HomeView(selectedView: $selectedView)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            TabBarView(selectedView: $selectedView)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    MainTabView()
}
