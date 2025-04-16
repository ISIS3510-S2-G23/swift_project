//
//  AccountView.swift
//  swift_app
//
//  Created by Juan Sebastian Pardo on 3/17/25.
//

import SwiftUI
import FirebaseCrashlytics
import FirebaseAnalytics

struct AccountView: View {
    @Binding var selectedView: Int
    @State private var showSignUp = false
    @EnvironmentObject var appState: AppState // For managing app-wide state
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.6))
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                
                // Illustration
                HStack {
                    Spacer()
                    Image("Person8")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    Spacer()
                }
                .padding(.bottom, 20)
                
                // Menu Options
                VStack(spacing: 25) {
                    Button(action: {
                        Crashlytics.crashlytics().log("Edit Account tapped - triggering test crash")
                        fatalError("Test Crash from Edit Account button")
                    }) {
                        Text("Edit Account")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        // Settings and Privacy action
                    }) {
                        Text("Settings and Privacy")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        // Help action
                    }) {
                        Text("Help")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Log out")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .onAppear {
                logScreen("AccountView")
            }
            .fullScreenCover(isPresented: $showSignUp) {
                OptionsView()
            }
        }
    }

  
    func logScreen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: name
        ])
    }
}

class AppState: ObservableObject {
    @Published var isLoggedIn = true
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(selectedView: .constant(4))
            .environmentObject(AppState())
    }
}
