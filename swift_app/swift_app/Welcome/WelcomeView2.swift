//
//  WelcomeView2.swift
//  swift_app
//
//  Created by Paulina Arrazola on 20/03/25.
//

import SwiftUI

struct WelcomeView2: View {
    @State private var navigateToOptionsView = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // MenPlant image from assets
            Image("MenPlant")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
                .padding(.bottom, 20)
            
            // Main text
            Text("Recycling has never been easier")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description text
            Text("Find nearby recycling points, complete challenges, earn rewards and connect with a committed community.")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            // Next button
            Button(action: {
                // Handle navigation to OptionsView
                navigateToOptionsView = true
            }) {
                Image("ArrowButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Hides the back button
        .navigationDestination(isPresented: $navigateToOptionsView) {
            OptionsView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct WelcomeView2_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView2()
    }
}
