//
//  LogInView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 12/03/25.
//
import SwiftUI

struct LoginView: View {
    @State private var email: String = "user@gmail.com"
    @State private var username: String = "User1"
    @State private var password: String = "******"
    @State private var confirmPassword: String = "******"
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Aquamarine stripe for the top section
                Color(hex: "A8DADC")
                    .frame(height: 200)
                
                // White background for the rest
                Color.white
            }
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Top section with title and subtitle
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sign up")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Enter details below and sign up")
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
                        Text("Your username")
                            .font(.system(size: 16))
                            .foregroundColor(Color.purple.opacity(0.7))
                        
                        TextField("", text: $username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password")
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
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Confirm your password")
                            .font(.system(size: 16))
                            .foregroundColor(Color.purple.opacity(0.7))
                        
                        ZStack {
                            if isConfirmPasswordVisible {
                                TextField("", text: $confirmPassword)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            } else {
                                SecureField("", text: $confirmPassword)
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
                                    isConfirmPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 16)
                            }
                        }
                    }
                    
                    Button(action: {
                        // Handle sign up action
                    }) {
                        // Use your asset:
                        Image("Long SignUp")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)
                    
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
        SignUpView()
    }
}
