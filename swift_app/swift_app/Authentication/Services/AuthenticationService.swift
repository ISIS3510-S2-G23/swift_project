//
//  AuthenticationService.swift
//  swift_app
//
//  Created by Paulina Arrazola on 17/03/25.
//
import FirebaseAuth
import Combine

class AuthenticationService: ObservableObject {
    @Published var currentFirebaseUser: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    @Published var isAuthenticating = false
    @Published var error: String?
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private func setupAuthStateListener() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.currentFirebaseUser = firebaseUser
            
            if let firebaseUser = firebaseUser {
                // Convert to your app's user model
                self?.currentUser = AppUser(from: firebaseUser)
                
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    init() {
        setupAuthStateListener()
    }
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    

    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isAuthenticating = true
        error = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.isAuthenticating = false
            
            if let error = error {
                self?.error = error.localizedDescription
                completion(false)
                return
            }
            
            if authResult?.user != nil {
                self?.error = nil
                completion(true)
            } else {
                self?.error = "Failed to sign in"
                completion(false)
            }
        }
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        // Note: This requires GoogleSignIn SDK integration
        // This is just a placeholder - you'll need to implement the actual Google Sign-In
        self.error = "Google Sign-In not yet implemented"
        completion(false)
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            self.error = error.localizedDescription
            return false
        }
    }
}
