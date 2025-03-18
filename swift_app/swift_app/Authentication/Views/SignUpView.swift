//
//  SignUpView.swift
//  swift_app
//
//  Created by Paulina Arrazola on 12/03/25.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
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
            
            VStack(alignment: .leading, spacing: 0) {
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
                    
                    Text("Sign Up")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 5)
                    
                    Text("Enter details below and sign up")
                        .font(.system(size: 20))
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(.bottom, 15)
                }
                .padding(.horizontal, 20)
                
                // Form fields in white area
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Your email")
                                .font(.system(size: 16))
                                .foregroundColor(Color.purple.opacity(0.7))
                            
                            TextField("", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
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
                                .autocapitalization(.none)
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
                                        .autocapitalization(.none)
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
                                        .autocapitalization(.none)
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
                            signUp()
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.278, green: 0.278, blue: 0.529))
                                    .cornerRadius(8)
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.278, green: 0.278, blue: 0.529))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Account login text
                        HStack {
                            Spacer()
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Log in")
                                    .foregroundColor(Color(red: 0.278, green: 0.278, blue: 0.529))
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.top, 5)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
                .background(Color.white)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // Function to handle the sign up process
    func signUp() {
        // Validation checks
        guard !email.isEmpty, !username.isEmpty, !password.isEmpty else {
            alertTitle = "Error"
            alertMessage = "Please fill all fields"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertTitle = "Error"
            alertMessage = "Passwords don't match"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertTitle = "Error"
            alertMessage = "Password should be at least 6 characters"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let db = Firestore.firestore()
            db.collection("users").whereField("username", isEqualTo: username).getDocuments { (snapshot, error) in
                if let error = error {
                    isLoading = false
                    alertTitle = "Error"
                    alertMessage = "Could not verify username availability: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                // If documents exist, username is taken
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    isLoading = false
                    alertTitle = "Username Taken"
                    alertMessage = "This username is already in use. Please choose another username."
                    showAlert = true
                    return
                }
            // Create user with email and password
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                isLoading = false
                
                if let error = error {
                    alertTitle = "Sign Up Failed"
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }
                
                guard let user = authResult?.user else {
                    alertTitle = "Error"
                    alertMessage = "Failed to create user"
                    showAlert = true
                    return
                }
                
                // Update display name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = username
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating profile: \(error.localizedDescription)")
                    }
                }
                
                // Save additional user data to Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "username": username,
                    "email": email,
                    "uid": user.uid,
                    "createdAt": Timestamp(date: Date())
                ]) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                        alertTitle = "Error"
                        alertMessage = "Account created but failed to save user data"
                        showAlert = true
                    } else {
                        // Success - go back to login
                        alertTitle = "Success"
                        alertMessage = "Your account has been created successfully!"
                        showAlert = true
                        // You might want to navigate to another view or dismiss this one
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
