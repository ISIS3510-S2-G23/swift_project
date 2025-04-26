//
//  NearMeView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/15/25.
//

import SwiftUI
import FirebaseAnalytics

struct NearMeView: View {
    @StateObject private var mapViewModel = MapViewModel()
        
    var body: some View {
        // Network status indicator
        if !mapViewModel.isConnected {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)
                Text("Offline Mode - Not all locations are available")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(8)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        VStack(alignment: .leading) {

            
            Text("Recycle points near you")
                .font(.headline)

            MapViewModelWrapper(mapViewModel: mapViewModel)
                .frame(width: 320, height: 400)
                .cornerRadius(12)
        }
        .padding(10)
        .frame(width: 350)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 5)
        )
        .onAppear { 
            logScreen("NearMeView")
        }
    }


    func logScreen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: name
        ])
    }
}

#Preview {
    NearMeView()
}
