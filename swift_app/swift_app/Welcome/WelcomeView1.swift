//
//  WelcomeView1.swift
//  swift_app
//
//  Created by Paulina Arrazola on 20/03/25.
//
import SwiftUI

struct WelcomeView1: View {
    @State private var navigateToWelcomeView2 = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Farmer image from assets
                Image("Farmer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .padding(.bottom, 20)
                
                // Welcome text
                Text("Welcome to EcoSphere!")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Description text
                Text("Discover a new way to recycle, share, and learn about sustainability in your community.")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // Next button
                Button(action: {
                    // Handle navigation to WelcomeView2
                    navigateToWelcomeView2 = true
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
            .navigationBarHidden(true) // Hides the navigation bar
            .navigationDestination(isPresented: $navigateToWelcomeView2) {
                WelcomeView2()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

struct WelcomeView1_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView1()
    }
}

