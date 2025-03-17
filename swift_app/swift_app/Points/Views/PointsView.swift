//
//  PointsView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/10/25.
//

import SwiftUI

struct PointsView: View {
    @State private var searchText: String = ""
    @State private var selectedTab: String = "Near Me"
    let categories = ["Near Me", "Challenges", "Rewards"]
    
    var body: some View {
        VStack {
            // Main title and image
            HStack {
                Text("Recycle points in Bogotá")
                    .font(.title2)
                    .foregroundStyle(.ecoMainPurple)
                    .fontWeight(.bold)

                Spacer()

                Image(.person8)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
            }
            .padding(.horizontal, 20)

            // Search bar
            TextField("Find locations", text: $searchText)
                .padding(15)
                .background(Color(.ecoLightPurple))
                .cornerRadius(29)
                .padding(.horizontal, 15)
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.ecoMainPurple)
                            .padding(.trailing, 40)
                    }
                )
                .foregroundStyle(.ecoMainPurple)

            // Category selection
            HStack {
                Text("Choose your preference")
                    .font(.headline)
                    .foregroundStyle(.ecoChooseBlue)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .padding(.leading, 20)
                Spacer()
            }

            HStack {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedTab = category
                    }) {
                        Text(category)
                            .fontWeight(selectedTab == category ? .bold : .regular)
                            .foregroundColor(.ecoMainPurple)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .frame(height: 3)
                                    .foregroundColor(selectedTab == category ? .ecoMainPurple.opacity(1) : .ecoMainPurple.opacity(0.3)),
                                alignment: .bottom
                            )
                    }
                }
            }
            .padding(.horizontal, 10)

            // Tab content
            Group {
                switch selectedTab {
                case "Near Me":
                    NearMeView()
                case "Challenges":
                    ChallengesView(selectedTab: $selectedTab) // Pass binding
                case "Rewards":
                    RewardsView()
                default:
                    EmptyView()
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
}

#Preview {
    PointsView()
}
