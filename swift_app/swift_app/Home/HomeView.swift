//
//  HomeView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/17/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedView: Int  // Allows switching views

    var body: some View {
        VStack {
            Text("Home: TODO")
                .font(.title)
                .padding()

            Spacer()

             // Include the tab bar at the bottom
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    HomeView(selectedView: .constant(0))
}
