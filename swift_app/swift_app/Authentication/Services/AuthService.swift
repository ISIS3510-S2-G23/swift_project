//
//  AuthService.swift
//  swift_app
//
//  Created by Paulina Arrazola on 6/03/25.
//
//
//import FirebaseAuth
//import FirebaseFirestore
//
//class AuthService {
//    static let shared = AuthService()
//    
//    private let auth = FirebaseManager.shared.auth
//    private let firestore = FirebaseManager.shared.firestore
//
//    func login(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
//        auth.signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let result = result else { return }
//            completion(.success(result))
//        }
//    }
//
//    func createUser(email: String, password: String, username: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
//        auth.createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                decompletion(.failure(error))
//                return
//            }
//            guard let result = result else { return }
//            
//            let userData: [String: Any] = [
//                "id": result.user.uid,
//                "username": username,
//                "email": email
//            ]
//            
//            self.firestore.collection("users").document(result.user.uid).setData(userData) { error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                completion(.success(result))
//            }
//        }
//    }
//
//    func signOut() {
//        do {
//            try auth.signOut()
//        } catch {
//            print("Error signing out: \(error.localizedDescription)")
//        }
//    }
//}
