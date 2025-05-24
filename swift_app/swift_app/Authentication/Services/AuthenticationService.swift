//
//  AuthenticationService.swift
//  swift_app
//
//  Created by Paulina Arrazola on 17/03/25.
//
import FirebaseAuth
import Combine
import Network

class AuthenticationService: ObservableObject {
    @Published var currentFirebaseUser: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    @Published var isAuthenticating = false
    @Published var error: String?
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private let networkMonitor = NWPathMonitor()
    @Published private(set) var isConnected = true
    
    private func setupAuthStateListener() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            self?.currentFirebaseUser = firebaseUser
            
            if let firebaseUser = firebaseUser {
                self?.currentUser = AppUser(from: firebaseUser)
                
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    init() {
        setupAuthStateListener()
        setupNetworkMonitoring()
    }
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
        networkMonitor.cancel()
    }
    

    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                self?.isConnected = (path.status == .satisfied)
                if !wasConnected && self?.isConnected == true {
                    print("Network reconnected")
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
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
