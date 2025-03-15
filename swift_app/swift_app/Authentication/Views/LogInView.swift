//
//  LogInView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 12/03/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = "user@gmail.com"
    @State private var password: String = "******"
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack(alignment: .top) {
                    // Background setup with explicit sizing
                    VStack(spacing: 0) {
                        // Fill the top 40% with aquamarine
                        Rectangle()
                            .fill(Color(hex: "A8DADC"))
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
                            .edgesIgnoringSafeArea(.top)
                        
                        Spacer()
                    }
                    
                    // Content overlay
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Top section with title and subtitle
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Log in")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.top, 20)
                                
                                Text("Enter details below and log in")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.black.opacity(0.6))
                                    .padding(.bottom, 15)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            
                            // Form content in a card-like container
                            VStack(spacing: 0) {
                                // Push content down in the white card
                                Spacer().frame(height: 0)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("Your email")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.purple.opacity(0.7))
                                    
                                    TextField("", text: $email)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Your password")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.purple.opacity(0.7))
                                    
                                    ZStack {
                                        if isPasswordVisible {
                                            TextField("", text: $password)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                                )
                                        } else {
                                            SecureField("", text: $password)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                                )
                                        }
                                        
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                isPasswordVisible.toggle()
                                            }) {
                                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding(.trailing, 16)
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    // Handle login action
                                }) {
                                    Image("Long Login")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.top, 10)
                                
                                // Account signup text
                                HStack {
                                    Spacer()
                                    Text("Don't have an account?")
                                        .foregroundColor(.gray)
                                    
                                    NavigationLink(destination: SignUpView()) {
                                        Text("Sign up")
                                            .foregroundColor(Color(hex: "474787"))
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                }
                                .padding(.top, 5)
                                
                                // Or login with section
                                HStack {
                                    VStack {
                                        Divider()
                                    }
                                    
                                    Text("Or login with")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 10)
                                    
                                    VStack {
                                        Divider()
                                    }
                                }
                                .padding(.vertical, 20)
                                
                                // Google login button
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        // Handle Google login
                                    }) {
                                        Image("Google logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    }
                                    Spacer()
                                }
                                
                                // Extra space at the bottom
                                Spacer().frame(height: 30)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            // Position this white container to start at 25% of screen height
                            .padding(.top, geometry.size.height * 0.25)
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
