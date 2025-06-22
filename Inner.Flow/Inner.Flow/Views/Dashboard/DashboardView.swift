//
//  DashboardView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showNewLog = false
    
    private var recentLogs: [DailyLog] {
        Array(dataManager.dailyLogs.prefix(5))
    }
    
    private var todayLog: DailyLog? {
        dataManager.dailyLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
    }
    
    private var averageMood: Double {
        guard !recentLogs.isEmpty else { return 0 }
        let totalScore = recentLogs.reduce(0) { $0 + $1.moodScore }
        return Double(totalScore) / Double(recentLogs.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Header
                        VStack(alignment: .leading, spacing: AppTheme.spacing) {
                            HStack {
                                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                                    Text("Welcome back,")
                                        .font(AppTheme.Typography.body)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text(authManager.userProfile?.name ?? "User")
                                        .font(AppTheme.Typography.title2)
                                        .foregroundColor(AppTheme.text)
                                }
                                
                                Spacer()
                                
                                Button(action: { showNewLog = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.primary)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.spacingLarge)
                        .padding(.top, AppTheme.spacingLarge)
                        
                        // Today's Status
                        if let todayLog = todayLog {
                            TodayStatusCard(log: todayLog)
                        } else {
                            NoLogTodayCard()
                        }
                        
                        // Quick Stats
                        QuickStatsView(averageMood: averageMood, totalLogs: dataManager.dailyLogs.count)
                        
                        // Recent Activity
                        RecentActivityView(logs: recentLogs)
                    }
                    .padding(.bottom, AppTheme.spacingExtraLarge)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                if let userId = authManager.user?.uid {
                    await dataManager.fetchDailyLogs(for: userId)
                }
            }
        }
        .sheet(isPresented: $showNewLog) {
            DailyLogFormView()
                .environmentObject(dataManager)
                .environmentObject(authManager)
        }
    }
}

struct TodayStatusCard: View {
    let log: DailyLog
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            HStack {
                Text("Today's Mood")
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.text)
                
                Spacer()
                
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            HStack {
                Text(log.mood)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Mood Score: \(log.moodScore)/10")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.text)
                    
                    if !log.notes.isEmpty {
                        Text(log.notes)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

struct NoLogTodayCard: View {
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary)
            
            Text("No log for today")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
            
            Text("Tap the + button to start your daily reflection")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

struct QuickStatsView: View {
    let averageMood: Double
    let totalLogs: Int
    
    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            StatCard(
                title: "Average Mood",
                value: String(format: "%.1f", averageMood),
                subtitle: "Last 5 days",
                icon: "heart.fill",
                color: AppTheme.primary
            )
            
            StatCard(
                title: "Total Logs",
                value: "\(totalLogs)",
                subtitle: "All time",
                icon: "book.fill",
                color: AppTheme.secondary
            )
        }
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.text)
            
            Text(title)
                .font(AppTheme.Typography.captionBold)
                .foregroundColor(AppTheme.text)
            
            Text(subtitle)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacing)
        .appCard()
    }
}

struct RecentActivityView: View {
    let logs: [DailyLog]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text("Recent Activity")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
                .padding(.horizontal, AppTheme.spacingLarge)
            
            if logs.isEmpty {
                VStack(spacing: AppTheme.spacing) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("No logs yet")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.spacingLarge)
                .appCard()
                .padding(.horizontal, AppTheme.spacingLarge)
            } else {
                ForEach(logs) { log in
                    RecentLogRow(log: log)
                }
            }
        }
    }
}

struct RecentLogRow: View {
    let log: DailyLog
    
    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            Text(log.mood)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.text)
                
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text("\(log.moodScore)/10")
                .font(AppTheme.Typography.captionBold)
                .foregroundColor(AppTheme.primary)
        }
        .padding(AppTheme.spacing)
        .appCard()
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 