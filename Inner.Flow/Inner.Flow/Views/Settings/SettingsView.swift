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
    @State private var showProfileEdit = false
    
    var body: some View {
        VStack {
            if let profile = authManager.userProfile {
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
            } else {
                Text("Loading Profile...")
            }
        }
        .sheet(isPresented: $showProfileEdit) {
            // Make sure ProfileEditView exists and is set up
            // ProfileEditView().environmentObject(authManager)
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

#Preview {
    SettingsView()
        .environmentObject(AuthenticationManager())
        .environmentObject(DataManager())
} 