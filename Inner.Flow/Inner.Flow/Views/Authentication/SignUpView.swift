//
//  SignUpView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && 
        password == confirmPassword && password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            VStack(spacing: AppTheme.spacing) {
                Text("Create Account")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.text)
                
                Text("Start your mood tracking journey")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            VStack(spacing: AppTheme.spacing) {
                // Name Field
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Full Name")
                        .font(AppTheme.Typography.captionBold)
                        .foregroundColor(AppTheme.text)
                    
                    TextField("Enter your full name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
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
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Confirm Password")
                        .font(AppTheme.Typography.captionBold)
                        .foregroundColor(AppTheme.text)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Password Requirements
                if !password.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                        Text("Password must be at least 6 characters")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(password.count >= 6 ? AppTheme.success : AppTheme.error)
                        
                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords don't match")
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.error)
                        }
                    }
                }
            }
            
            // Sign Up Button
            Button(action: signUp) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Create Account")
                            .font(AppTheme.Typography.bodyBold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .appButton()
            .disabled(authManager.isLoading || !isFormValid)
            
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
    }
    
    private func signUp() {
        Task {
            await authManager.signUp(email: email, password: password, name: name)
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationManager())
} 