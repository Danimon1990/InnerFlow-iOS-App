//
//  AnalyticsView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTimeframe: Timeframe = .week
    @State private var moodTrends: [DailyLog] = []
    @State private var isLoading = false
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Timeframe Selector
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                                Text(timeframe.rawValue).tag(timeframe)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, AppTheme.spacingLarge)
                        .padding(.top, AppTheme.spacingLarge)
                        .onChange(of: selectedTimeframe) { _, _ in
                            loadMoodTrends()
                        }
                        
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(AppTheme.spacingExtraLarge)
                        } else if moodTrends.isEmpty {
                            EmptyAnalyticsView()
                        } else {
                            // Statistics
                            StatisticsView(logs: moodTrends)
                                .padding(.horizontal, AppTheme.spacingLarge)
                            
                            // Mood Distribution
                            MoodDistributionView(logs: moodTrends)
                                .padding(.horizontal, AppTheme.spacingLarge)
                            
                            // Activity Analysis
                            ActivityAnalysisView(logs: moodTrends)
                                .padding(.horizontal, AppTheme.spacingLarge)
                        }
                    }
                    .padding(.bottom, AppTheme.spacingExtraLarge)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                loadMoodTrends()
            }
        }
        .onAppear {
            loadMoodTrends()
        }
    }
    
    private func loadMoodTrends() {
        guard let userId = authManager.user?.uid else { return }
        
        isLoading = true
        
        Task {
            moodTrends = await dataManager.getMoodTrends(for: userId, days: selectedTimeframe.days)
            isLoading = false
        }
    }
}

struct EmptyAnalyticsView: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.primary)
            
            VStack(spacing: AppTheme.spacing) {
                Text("No Data Available")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.text)
                
                Text("Start logging your daily moods to see analytics and trends")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.spacingExtraLarge)
    }
}

struct StatisticsView: View {
    let logs: [DailyLog]
    
    private var averageMood: Double {
        guard !logs.isEmpty else { return 0 }
        let totalScore = logs.reduce(0) { $0 + $1.moodScore }
        return Double(totalScore) / Double(logs.count)
    }
    
    private var bestMood: Int {
        logs.map { $0.moodScore }.max() ?? 0
    }
    
    private var worstMood: Int {
        logs.map { $0.moodScore }.min() ?? 0
    }
    
    private var totalEntries: Int {
        logs.count
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Text("Statistics")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppTheme.spacing) {
                StatisticCard(
                    title: "Average Mood",
                    value: String(format: "%.1f", averageMood),
                    icon: "heart.fill",
                    color: AppTheme.primary
                )
                
                StatisticCard(
                    title: "Total Entries",
                    value: "\(totalEntries)",
                    icon: "book.fill",
                    color: AppTheme.secondary
                )
                
                StatisticCard(
                    title: "Best Day",
                    value: "\(bestMood)/10",
                    icon: "star.fill",
                    color: AppTheme.success
                )
                
                StatisticCard(
                    title: "Lowest Day",
                    value: "\(worstMood)/10",
                    icon: "arrow.down.circle.fill",
                    color: AppTheme.warning
                )
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.Typography.title3)
                .foregroundColor(AppTheme.text)
            
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacing)
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadius)
    }
}

struct MoodDistributionView: View {
    let logs: [DailyLog]
    
    private var moodCounts: [String: Int] {
        Dictionary(grouping: logs, by: { $0.mood })
            .mapValues { $0.count }
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Text("Mood Distribution")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
            
            if moodCounts.isEmpty {
                Text("No mood data available")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                VStack(spacing: AppTheme.spacingSmall) {
                    ForEach(Array(moodCounts.sorted(by: { $0.value > $1.value })), id: \.key) { mood, count in
                        HStack {
                            Text(mood)
                                .font(.system(size: 24))
                            
                            Text("\(count) times")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.text)
                            
                            Spacer()
                            
                            Text("\(Int(Double(count) / Double(logs.count) * 100))%")
                                .font(AppTheme.Typography.captionBold)
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(AppTheme.spacingSmall)
                        .background(AppTheme.tertiary)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                    }
                }
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
    }
}

struct ActivityAnalysisView: View {
    let logs: [DailyLog]
    
    private var activityCounts: [String: Int] {
        var counts: [String: Int] = [:]
        for log in logs {
            for activity in log.activities {
                counts[activity, default: 0] += 1
            }
        }
        return counts
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacing) {
            Text("Most Common Activities")
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.text)
            
            if activityCounts.isEmpty {
                Text("No activity data available")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
            } else {
                VStack(spacing: AppTheme.spacingSmall) {
                    ForEach(Array(activityCounts.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { activity, count in
                        HStack {
                            Text(activity)
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.text)
                            
                            Spacer()
                            
                            Text("\(count) times")
                                .font(AppTheme.Typography.captionBold)
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(AppTheme.spacingSmall)
                        .background(AppTheme.tertiary)
                        .cornerRadius(AppTheme.cornerRadiusSmall)
                    }
                }
            }
        }
        .padding(AppTheme.spacingLarge)
        .appCard()
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 