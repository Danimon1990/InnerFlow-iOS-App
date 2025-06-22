//
//  SettingsView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showProfileEdit = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Profile Section
                        ProfileSection()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // App Settings
                        AppSettingsSection()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Data & Privacy
                        DataPrivacySection()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // About
                        AboutSection()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Sign Out
                        SignOutSection()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        
                        Spacer(minLength: AppTheme.spacingExtraLarge)
                    }
                    .padding(.vertical, AppTheme.spacingLarge)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditView()
                    .environmentObject(dataManager)
                    .environmentObject(authManager)
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ProfileSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showProfileEdit = false
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            HStack {
                Text("Profile")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.text)
                
                Spacer()
                
                Button("Edit") {
                    showProfileEdit = true
                }
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.primary)
            }
            
            VStack(spacing: AppTheme.spacing) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppTheme.primary)
                    
                    VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                        Text(authManager.userProfile?.name ?? "User")
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundColor(AppTheme.text)
                        
                        Text(authManager.userProfile?.email ?? "")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("Member since \(authManager.userProfile?.createdAt.formatted(date: .abbreviated, time: .omitted) ?? "")")
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
        .sheet(isPresented: $showProfileEdit) {
            ProfileEditView()
                .environmentObject(authManager)
        }
    }
}

struct AppSettingsSection: View {
    @State private var dailyReminder = true
    @State private var weeklyReport = true
    @State private var darkMode = false
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Text("App Settings")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppTheme.spacingSmall) {
                SettingRow(
                    icon: "bell.fill",
                    title: "Daily Reminder",
                    subtitle: "Get reminded to log your mood",
                    isToggle: true,
                    toggleValue: $dailyReminder
                )
                
                SettingRow(
                    icon: "chart.bar.fill",
                    title: "Weekly Report",
                    subtitle: "Receive weekly mood summary",
                    isToggle: true,
                    toggleValue: $weeklyReport
                )
                
                SettingRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Use dark theme",
                    isToggle: true,
                    toggleValue: $darkMode
                )
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
    }
}

struct DataPrivacySection: View {
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Text("Data & Privacy")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppTheme.spacingSmall) {
                SettingRow(
                    icon: "lock.fill",
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    isToggle: false
                )
                
                SettingRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    isToggle: false
                )
                
                SettingRow(
                    icon: "trash.fill",
                    title: "Delete Account",
                    subtitle: "Permanently delete your account",
                    isToggle: false
                )
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
    }
}

struct AboutSection: View {
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Text("About")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppTheme.spacingSmall) {
                SettingRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: "1.0.0",
                    isToggle: false
                )
                
                SettingRow(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    subtitle: "Get help and support",
                    isToggle: false
                )
                
                SettingRow(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Rate us on the App Store",
                    isToggle: false
                )
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
    }
}

struct SignOutSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showSignOutAlert = false
    
    var body: some View {
        Button(action: { showSignOutAlert = true }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.error)
                
                Text("Sign Out")
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.error)
                
                Spacer()
            }
            .padding(AppTheme.spacingLarge)
            .appCard()
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isToggle: Bool
    @Binding var toggleValue: Bool
    
    init(icon: String, title: String, subtitle: String, isToggle: Bool, toggleValue: Binding<Bool> = .constant(false)) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isToggle = isToggle
        self._toggleValue = toggleValue
    }
    
    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                Text(title)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.text)
                
                Text(subtitle)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            if isToggle {
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(AppTheme.spacing)
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadiusSmall)
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 