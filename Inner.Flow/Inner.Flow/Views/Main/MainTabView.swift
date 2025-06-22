//
//  MainTabView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            DailyLogView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Daily Log")
                }
            
            AnalyticsView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
            
            SettingsView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(AppTheme.primary)
        .onAppear {
            if let userId = authManager.user?.uid {
                Task {
                    await dataManager.fetchUserProfile(for: userId)
                    await dataManager.fetchDailyLogs(for: userId)
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
} 