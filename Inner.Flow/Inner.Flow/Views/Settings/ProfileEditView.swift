//
//  ProfileEditView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var dailyReminder = true
    @State private var weeklyReport = true
    @State private var isLoading = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Profile Picture Section
                        VStack(spacing: AppTheme.spacing) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppTheme.primary)
                            
                            Text("Profile Picture")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Personal Information
                        VStack(spacing: AppTheme.spacing) {
                            Text("Personal Information")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                                Text("Full Name")
                                    .font(AppTheme.Typography.captionBold)
                                    .foregroundColor(AppTheme.text)
                                
                                TextField("Enter your full name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                            
                            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                                Text("Email")
                                    .font(AppTheme.Typography.captionBold)
                                    .foregroundColor(AppTheme.text)
                                
                                Text(authManager.userProfile?.email ?? "")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .padding(AppTheme.spacing)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(AppTheme.cornerRadiusSmall)
                            }
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Notification Settings
                        VStack(spacing: AppTheme.spacing) {
                            Text("Notification Settings")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: AppTheme.spacingSmall) {
                                HStack {
                                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                                        Text("Daily Reminder")
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(AppTheme.text)
                                        
                                        Text("Get reminded to log your mood daily")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $dailyReminder)
                                        .labelsHidden()
                                }
                                .padding(AppTheme.spacing)
                                .background(Color.white)
                                .cornerRadius(AppTheme.cornerRadiusSmall)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                                        Text("Weekly Report")
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(AppTheme.text)
                                        
                                        Text("Receive weekly mood summary")
                                            .font(AppTheme.Typography.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $weeklyReport)
                                        .labelsHidden()
                                }
                                .padding(AppTheme.spacing)
                                .background(Color.white)
                                .cornerRadius(AppTheme.cornerRadiusSmall)
                            }
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Save Button
                        Button(action: saveProfile) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Save Changes")
                                        .font(AppTheme.Typography.bodyBold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .appButton()
                        .disabled(isLoading || name.isEmpty)
                        .padding(.horizontal, AppTheme.spacingLarge)
                        .padding(.bottom, AppTheme.spacingLarge)
                    }
                }
            }
            .navigationTitle("Edit Profile")
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
        .onAppear {
            loadCurrentProfile()
        }
        .overlay(
            Group {
                if showSuccess {
                    SuccessOverlay()
                }
            }
        )
    }
    
    private func loadCurrentProfile() {
        if let profile = authManager.userProfile {
            name = profile.name
            dailyReminder = profile.notificationSettings.dailyReminder
            weeklyReport = profile.notificationSettings.weeklyReport
        }
    }
    
    private func saveProfile() {
        guard let userId = authManager.user?.uid,
              let currentProfile = authManager.userProfile else { return }
        
        isLoading = true
        
        let updatedProfile = UserProfile(
            name: name,
            email: currentProfile.email,
            createdAt: currentProfile.createdAt,
            notificationSettings: NotificationSettings(
                dailyReminder: dailyReminder,
                weeklyReport: weeklyReport
            )
        )
        
        Task {
            await dataManager.updateUserProfile(updatedProfile, for: userId)
            isLoading = false
            showSuccess = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showSuccess = false
                dismiss()
            }
        }
    }
}

struct SuccessOverlay: View {
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.success)
            
            Text("Profile Updated!")
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.text)
        }
        .padding(AppTheme.spacingLarge)
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(radius: 10)
        .transition(.scale.combined(with: .opacity))
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 