//
//  DashboardView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showNewLog = false
    
    private var recentLogs: [DailyLog] {
        Array(dataManager.dailyLogs.prefix(7))
    }
    
    private var todayLog: DailyLog? {
        dataManager.dailyLogs.first { log in
            Calendar.current.isDate(log.date, inSameDayAs: Date())
        }
    }
    
    private var averageMood: Double {
        guard !recentLogs.isEmpty else { return 0 }
        let totalScore = recentLogs.reduce(0) { $0 + $1.generalMood }
        return Double(totalScore) / Double(recentLogs.count)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        HeaderView(name: authManager.userProfile?.name ?? "User", showNewLog: $showNewLog)
                        
                        if let todayLog = todayLog {
                            TodayStatusCard(log: todayLog)
                        } else {
                            NoLogTodayCard(showNewLog: $showNewLog)
                        }
                        
                        MoodTrendChart(logs: recentLogs)
                        
                        QuickStatsView(averageMood: averageMood, totalLogs: dataManager.dailyLogs.count)
                        
                        RecentActivityView(logs: Array(dataManager.dailyLogs.prefix(3)))
                    }
                    .padding(.bottom, AppTheme.spacingExtraLarge)
                }
            }
            .navigationTitle("Dashboard")
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

// MARK: - Subviews

struct HeaderView: View {
    let name: String
    @Binding var showNewLog: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                Text("Welcome back,")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
                Text(name)
                    .font(AppTheme.Typography.title2)
            }
            Spacer()
            Button(action: { showNewLog = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.primary)
            }
        }
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

struct TodayStatusCard: View {
    let log: DailyLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing) {
            Text("Today's Summary")
                .font(AppTheme.Typography.headline)
            
            HStack(spacing: AppTheme.spacingLarge) {
                StatusItem(title: "Mood", value: "\(log.generalMood)/10", icon: "face.smiling")
                StatusItem(title: "Energy", value: "\(log.generalEnergy)/10", icon: "bolt.fill")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

struct StatusItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.primary)
            VStack(alignment: .leading) {
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(value)
                    .font(AppTheme.Typography.bodyBold)
            }
        }
    }
}

struct NoLogTodayCard: View {
    @Binding var showNewLog: Bool
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Image(systemName: "book.closed")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.primary)
            
            Text("No Log for Today")
                .font(AppTheme.Typography.headline)
            
            Button("Log Your Day") {
                showNewLog = true
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
        .padding(.horizontal, AppTheme.spacingLarge)
    }
}

struct MoodTrendChart: View {
    let logs: [DailyLog]

    var body: some View {
        VStack(alignment: .leading) {
            Text("7-Day Mood Trend")
                .font(.headline)
                .padding(.horizontal, AppTheme.spacingLarge)

            Chart(logs) { log in
                LineMark(
                    x: .value("Date", log.date, unit: .day),
                    y: .value("Mood", log.generalMood)
                )
                .foregroundStyle(AppTheme.primary)
                
                PointMark(
                    x: .value("Date", log.date, unit: .day),
                    y: .value("Mood", log.generalMood)
                )
                .foregroundStyle(AppTheme.primary)
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .frame(height: 150)
            .padding(AppTheme.spacing)
            .appCard()
            .padding(.horizontal, AppTheme.spacingLarge)
        }
    }
}

struct QuickStatsView: View {
    let averageMood: Double
    let totalLogs: Int
    
    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            StatCard(
                title: "Avg. Mood",
                value: String(format: "%.1f", averageMood),
                subtitle: "Last 7 days",
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
        VStack(alignment: .center, spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Typography.title3)
            
            Text(title)
                .font(AppTheme.Typography.captionBold)
            
            Text(subtitle)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
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
                .padding(.horizontal, AppTheme.spacingLarge)
            
            if logs.isEmpty {
                Text("No recent logs.")
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(AppTheme.spacingLarge)
                    .frame(maxWidth: .infinity)
                    .appCard()
                    .padding(.horizontal, AppTheme.spacingLarge)

            } else {
                ForEach(logs) { log in
                    DailyLogCard(log: log)
                        .padding(.horizontal, AppTheme.spacingLarge)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 