//
//  TabBarView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/17/25.
//

import SwiftUI

struct TabBarView: View {
    @Binding var selectedView: Int  // Controls which tab is active

    var body: some View {
        HStack {
            TabBarButton(image: "house", label: "Home", index: 0, selectedView: $selectedView)
            TabBarButton(image: "mappin.circle", label: "Points", index: 1, selectedView: $selectedView)
            
            Button(action: {
                selectedView = 2
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.ecoMainPurple)
                    .background(Color.white.clipShape(Circle()).shadow(radius: 4))
            }
            .offset(y: -4) // Lift the middle button up slightly
            
            TabBarButton(image: "bell", label: "Notifications", index: 3, selectedView: $selectedView)
            TabBarButton(image: "person.circle", label: "Account", index: 4, selectedView: $selectedView)
        }
        .padding(.vertical, 10)
        .background(Color.white.shadow(radius: 4))
    }
}

struct TabBarButton: View {
    let image: String
    let label: String
    let index: Int
    @Binding var selectedView: Int

    var body: some View {
        Button(action: {
            selectedView = index
        }) {
            VStack {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(selectedView == index ? .ecoMainPurple : .gray)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(selectedView == index ? .bold : .regular) // <-- Make it bold when selected
                    .foregroundColor(selectedView == index ? .ecoMainPurple : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TabBarView(selectedView: .constant(1))
}
