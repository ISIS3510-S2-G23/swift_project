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
        VStack{
            HStack{
                Text("Recycle points in Bogotá")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 15)
                    .padding(.leading, 15)
                Spacer()
            }
            TextField("Find locations", text: $searchText)
                .padding(15)
                .background(Color(.systemGray6))
                .cornerRadius(29)
                .padding(.horizontal, 15)
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 40)
                    }
                )
            HStack{
                Text("Choose your preference")
                    .font(.headline)
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
                            .foregroundColor(.purple)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Rectangle()
                                    .frame(height: 3)
                                    .foregroundColor(selectedTab == category ? .purple.opacity(1) : .purple.opacity(0.3)),
                                alignment: .bottom
                            )
                    }
                }
                
            }
            .padding(.horizontal, 10)
            Spacer()
        }
        
    }
}

#Preview {
    PointsView()
}

