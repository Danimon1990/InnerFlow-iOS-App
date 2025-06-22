//
//  ForgotPasswordView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.spacingExtraLarge) {
                    // Header
                    VStack(spacing: AppTheme.spacing) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.primary)
                        
                        Text("Reset Password")
                            .font(AppTheme.Typography.title2)
                            .foregroundColor(AppTheme.text)
                        
                        Text("Enter your email address and we'll send you a link to reset your password")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppTheme.spacingExtraLarge)
                    
                    Spacer()
                    
                    // Form
                    VStack(spacing: AppTheme.spacingLarge) {
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
                        
                        // Reset Button
                        Button(action: resetPassword) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Send Reset Link")
                                        .font(AppTheme.Typography.bodyBold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .appButton()
                        .disabled(authManager.isLoading || email.isEmpty)
                        
                        // Error Message
                        if let errorMessage = authManager.errorMessage {
                            Text(errorMessage)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.error)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Success Message
                        if showSuccess {
                            VStack(spacing: AppTheme.spacingSmall) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(AppTheme.success)
                                
                                Text("Reset link sent!")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.success)
                                
                                Text("Check your email for instructions to reset your password")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(AppTheme.spacingLarge)
                            .appCard()
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingLarge)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
    
    private func resetPassword() {
        Task {
            await authManager.resetPassword(email: email)
            if authManager.errorMessage == nil {
                showSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthenticationManager())
} 