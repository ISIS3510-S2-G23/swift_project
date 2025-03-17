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
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Aquamarine stripe for the top section
                Color(red: 0.659, green: 0.855, blue: 0.863)
                    .frame(height: 220)
                
                // White background for the rest
                Color.white
            }
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 40) {
                // Top section with title and subtitle
                VStack(alignment: .leading, spacing: 10) {
                    // Back button above the title
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    Text("Log in")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 5)
                    
                    Text("Enter details below and log in")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(.bottom, 15)
                }
                .padding(.horizontal, 20)
                
                // Form fields in white area
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
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
                    
                    VStack(alignment: .leading, spacing: 5) {
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
                        
                        NavigationLink(destination: SignUpView().navigationBarBackButtonHidden(true)) {
                            Text("Sign up")
                                .foregroundColor(Color(red: 0.278, green: 0.278, blue: 0.529))
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
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
