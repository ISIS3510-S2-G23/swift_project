//
//  LogInView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 12/03/25.
//

import SwiftUI

struct OptionsView: View {
    // Define customizable colors
    let backgroundColor = Color.white
    let primaryTextColor = Color(#colorLiteral(red: 0.427, green: 0.419, blue: 0.647, alpha: 1))
    let secondaryTextColor = Color.gray
    let buttonBackgroundColor = Color(#colorLiteral(red: 0.721, green: 0.871, blue: 0.871, alpha: 1))
    let buttonTextColor = Color(#colorLiteral(red: 0.251, green: 0.239, blue: 0.412, alpha: 1))
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image("Figure 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Join the community")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)
                
                Text("Create an account or log in to start your journey toward a more sustainable world!")
                    .font(.body)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // Buttons
                HStack(spacing: 20) {
                    NavigationLink(destination: LoginView()) {
                        Image("Login Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                    
                    Button(action: {
                        // Action for Sign up
                    }) {
                        Image("Sign Up Button")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .background(backgroundColor.ignoresSafeArea())
        }
    }
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}
