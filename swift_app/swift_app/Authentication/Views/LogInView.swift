//
//  LogInView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 12/03/25.
//import SwiftUI
import FirebaseAuth
import SwiftUICore
import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var authService = AuthenticationService()
    @State private var showAlert = false
    @State private var navigateToHome = false
    @State private var selectedViewIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Aquamarine stripe for the top section
                    Color(red: 0.659, green: 0.855, blue: 0.863)
                        .frame(height: 230)
                    
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
                    
                    // Network status indicator
                    if !authService.isConnected {
                        HStack {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.orange)
                            Text("Offline Mode - Log In will not be available without network connectivity")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(8)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
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
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never) // Prevents auto-capitalization
                                .disabled(authService.isAuthenticating)
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
                                        .textInputAutocapitalization(.never) // Ensures no auto-capitalization
                                        .disabled(authService.isAuthenticating)
                                } else {
                                    SecureField("", text: $password)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                        .textInputAutocapitalization(.never) // Ensures no auto-capitalization
                                        .disabled(authService.isAuthenticating)
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
                                    .disabled(authService.isAuthenticating)
                                }
                            }
                        }
                        
                        Button(action: {
                            login()
                        }) {
                            if authService.isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.278, green: 0.278, blue: 0.529))
                                    .cornerRadius(8)
                            } else {
                                Text("Log In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.278, green: 0.278, blue: 0.529))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 10)
                        .disabled(authService.isAuthenticating || email.isEmpty || password.isEmpty)
                        
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
                                loginWithGoogle()
                            }) {
                                Image("Google logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            .disabled(authService.isAuthenticating)
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .background(Color.white)
                }
                
                // Navigation after successful authentication
                .navigationDestination(isPresented: $navigateToHome) {
                    MainTabView()
                    .navigationBarBackButtonHidden(true)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(authService.error ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func login() {
        authService.signIn(email: email, password: password) { success in
            if success {
                navigateToHome = true
            } else {
                showAlert = true
            }
        }
    }
    
    private func loginWithGoogle() {
        authService.signInWithGoogle { success in
            if success {
                navigateToHome = true
            } else {
                showAlert = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
