//
//  NearMeView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/15/25.
//

import SwiftUI

struct NearMeView: View {
    var body: some View {
        VStack(alignment: .leading) { 
            Text("Recycle points near you")
                .font(.headline)

            MapViewModelWrapper()
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
    }
}

#Preview {
    NearMeView()
}

