//
//  SettingsView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showSignOutAlert = false
    
    // Create bindings that also save the data on change
    private var notificationSettings: Binding<NotificationSettings> {
        Binding(
            get: { authManager.userProfile?.notificationSettings ?? NotificationSettings() },
            set: { newSettings in
                guard var profile = authManager.userProfile, let userId = authManager.user?.uid else { return }
                profile.notificationSettings = newSettings
                authManager.userProfile = profile // Update local state immediately
                
                Task {
                    await dataManager.updateUserProfile(profile, for: userId)
                }
            }
        )
    }
    
    private var trackingSettings: Binding<TrackingSettings> {
        Binding(
            get: { authManager.userProfile?.trackingSettings ?? TrackingSettings() },
            set: { newSettings in
                guard var profile = authManager.userProfile, let userId = authManager.user?.uid else { return }
                profile.trackingSettings = newSettings
                authManager.userProfile = profile // Update local state immediately
                
                Task {
                    await dataManager.updateUserProfile(profile, for: userId)
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Profile")) {
                        ProfileSection()
                    }
                    
                    Section(header: Text("Notifications")) {
                        AppSettingsSection(settings: notificationSettings)
                    }
                    
                    Section(header: Text("Tracking Preferences")) {
                        TrackingSettingsSection(settings: trackingSettings)
                    }

                    Section(header: Text("Data & Privacy")) {
                        DataPrivacySection()
                    }

                    Section(header: Text("Debug")) {
                        DebugSection()
                    }

                    Section(header: Text("About")) {
                        AboutSection()
                    }
                    
                    Section {
                        SignOutSection(showSignOutAlert: $showSignOutAlert)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .onAppear {
                print("SettingsView appeared")
                print("AuthManager userProfile: \(authManager.userProfile?.name ?? "nil")")
                print("DataManager userProfile: \(dataManager.userProfile?.name ?? "nil")")
                print("AuthManager isLoading: \(authManager.isLoading)")
                print("DataManager isLoading: \(dataManager.isLoading)")
                
                // Ensure we have the latest user profile
                if let userId = authManager.user?.uid {
                    Task {
                        await dataManager.fetchUserProfile(for: userId)
                    }
                }
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

// MARK: - Sections

struct ProfileSection: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showProfileEdit = false
    
    var body: some View {
        VStack {
            if dataManager.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading Profile...")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
            } else if let profile = dataManager.userProfile {
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.primary)
                        
                        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                            Text(profile.name)
                                .font(AppTheme.Typography.bodyBold)
                            Text(profile.email)
                                .font(AppTheme.Typography.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Button("Edit") { showProfileEdit = true }
                    }
                    
                    // Profile details
                    VStack(alignment: .leading, spacing: 4) {
                        if let lastName = profile.lastName, !lastName.isEmpty {
                            ProfileDetailRow(label: "Last Name", value: lastName)
                        }
                        if let age = profile.age {
                            ProfileDetailRow(label: "Age", value: "\(age) years")
                        }
                        if let gender = profile.gender {
                            ProfileDetailRow(label: "Gender", value: gender.rawValue)
                        }
                        if let weight = profile.weight {
                            ProfileDetailRow(label: "Weight", value: "\(String(format: "%.1f", weight)) kg")
                        }
                        if let height = profile.height {
                            ProfileDetailRow(label: "Height", value: "\(String(format: "%.1f", height)) cm")
                        }
                        if let medicalCondition = profile.medicalCondition, !medicalCondition.isEmpty {
                            ProfileDetailRow(label: "Medical Conditions", value: medicalCondition)
                        }
                        if let medicines = profile.medicines, !medicines.isEmpty {
                            ProfileDetailRow(label: "Medicines", value: medicines)
                        }
                        if let bloodType = profile.bloodType {
                            ProfileDetailRow(label: "Blood Type", value: bloodType.rawValue)
                        }
                        if let familyHistory = profile.familyHistory, !familyHistory.isEmpty {
                            ProfileDetailRow(label: "Family History", value: familyHistory)
                        }
                        if let goal = profile.goal, !goal.isEmpty {
                            ProfileDetailRow(label: "Health Goal", value: goal)
                        }
                    }
                    .padding(.leading, 60) // Align with the profile info above
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.error)
                    Text("Failed to load profile")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.error)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showProfileEdit) {
            ProfileEditView()
                .environmentObject(authManager)
                .environmentObject(dataManager)
        }
    }
}

struct AppSettingsSection: View {
    @Binding var settings: NotificationSettings
    
    var body: some View {
        Toggle("Daily Reminder", isOn: $settings.dailyReminder)
        Toggle("Weekly Report", isOn: $settings.weeklyReport)
    }
}

struct TrackingSettingsSection: View {
    @Binding var settings: TrackingSettings
    
    var body: some View {
        Toggle("Track Mood", isOn: $settings.trackMood)
        Toggle("Track Energy", isOn: $settings.trackEnergy)
        Toggle("Track Sleep", isOn: $settings.trackSleep)
        Toggle("Track Stress", isOn: $settings.trackStress)
        Toggle("Track Target Symptoms", isOn: $settings.trackSymptoms)
        Toggle("Track Food", isOn: $settings.trackFood)
        Toggle("Track Medicines", isOn: $settings.trackMedicines)
        Toggle("Track Digestion", isOn: $settings.trackDigestion)
        Toggle("Track Moon Cycle", isOn: $settings.trackMoonCycle)
        Toggle("Track Pain", isOn: $settings.trackPain)
        Toggle("Track Notes", isOn: $settings.trackNotes)
    }
}

struct DataPrivacySection: View {
    var body: some View {
        NavigationLink("Privacy Policy", destination: Text("Privacy Policy Page"))
        NavigationLink("Terms of Service", destination: Text("Terms of Service Page"))
        Button(action: {
            // Handle account deletion
        }) {
            Text("Delete Account").foregroundColor(AppTheme.error)
        }
    }
}

struct AboutSection: View {
    var body: some View {
        HStack {
            Text("Version")
            Spacer()
            Text("1.0.0 (Build 1)")
                .foregroundColor(AppTheme.textSecondary)
        }
        NavigationLink("Contact Support", destination: Text("Support Page"))
        Button("Rate on App Store") {
            // Link to app store
        }
    }
}

struct DebugSection: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var testResult: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("User ID: \(authManager.user?.uid ?? "Not available")")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
            
            Text("Auth Profile: \(authManager.userProfile?.name ?? "Not loaded")")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
            
            Text("Data Profile: \(dataManager.userProfile?.name ?? "Not loaded")")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
            
            if !testResult.isEmpty {
                Text("Test Result: \(testResult)")
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(testResult.contains("success") ? .green : .red)
            }
            
            Button("Test Firebase Connection") {
                Task {
                    let result = await dataManager.testFirebaseConnection()
                    testResult = result ? "Success" : "Failed"
                }
            }
            .disabled(dataManager.isLoading)
            
            if dataManager.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
}

struct SignOutSection: View {
    @Binding var showSignOutAlert: Bool
    
    var body: some View {
        Button(action: { showSignOutAlert = true }) {
            HStack {
                Spacer()
                Text("Sign Out")
                    .foregroundColor(AppTheme.error)
                    .bold()
                Spacer()
            }
        }
    }
}

struct ProfileDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.text)
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
        .environmentObject(DataManager())
} 