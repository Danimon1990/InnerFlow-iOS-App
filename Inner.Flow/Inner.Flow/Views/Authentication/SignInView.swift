//
//  SignInView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            VStack(spacing: AppTheme.spacing) {
                Text("Welcome Back")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.text)
                
                Text("Sign in to continue your journey")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            VStack(spacing: AppTheme.spacing) {
                // Email Field
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Email")
                        .font(AppTheme.Typography.captionBold)
                        .foregroundColor(AppTheme.text)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Password")
                        .font(AppTheme.Typography.captionBold)
                        .foregroundColor(AppTheme.text)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Forgot Password
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.primary)
                }
            }
            
            // Sign In Button
            Button(action: signIn) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .font(AppTheme.Typography.bodyBold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .appButton()
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
            
            // Error Message
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.error)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppTheme.spacingSmall)
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
    
    private func signIn() {
        Task {
            await authManager.signIn(email: email, password: password)
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthenticationManager())
} 