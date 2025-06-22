//
//  AuthenticationView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

enum AuthMode {
    case signIn
    case signUp
}

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isSignUp: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(initialMode: AuthMode = .signIn) {
        self._isSignUp = State(initialValue: initialMode == .signUp)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.spacingExtraLarge) {
                    // Header
                    VStack(spacing: AppTheme.spacing) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Inner Flow")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.text)
                        
                        Text("Track your daily mood and reflections")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppTheme.spacingExtraLarge)
                    
                    Spacer()
                    
                    // Authentication Form
                    if isSignUp {
                        SignUpView()
                    } else {
                        SignInView()
                    }
                    
                    Spacer()
                    
                    // Toggle between Sign In and Sign Up
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding(.bottom, AppTheme.spacingLarge)
                }
                .padding(.horizontal, AppTheme.spacingLarge)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
                .foregroundColor(AppTheme.primary)
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
} 