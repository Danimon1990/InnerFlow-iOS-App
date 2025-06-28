//
//  AnalyticsView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable, Identifiable {
        var id: String { rawValue }
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
    
    private var filteredLogs: [DailyLog] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeframe.days, to: endDate) ?? endDate
        
        return dataManager.dailyLogs.filter { log in
            return log.date >= startDate && log.date <= endDate
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Analytics")) {
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, AppTheme.spacingLarge)
                    .padding(.top, AppTheme.spacingLarge)
                    
                    if filteredLogs.isEmpty {
                        EmptyAnalyticsView()
                    } else {
                        TrendChartView(logs: filteredLogs)
                        StatisticsGridView(logs: filteredLogs)
                    }
                }
                Section(header: Text("AI Insights")) {
                    NavigationLink(destination: AnalysisView().environmentObject(dataManager).environmentObject(authManager)) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.purple)
                            Text("Flow AI Wellness Insights")
                        }
                    }
                }
            }
            .navigationTitle("Analytics")
            .refreshable {
                if let userId = authManager.user?.uid {
                    await dataManager.fetchDailyLogs(for: userId)
                }
            }
        }
    }
}

// MARK: - Subviews

struct EmptyAnalyticsView: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.primary)
            
            Text("Not Enough Data")
                .font(AppTheme.Typography.title2)
            
            Text("Log your daily progress for a few days to see your trends and analytics.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(AppTheme.spacingExtraLarge)
    }
}

struct TrendChartView: View {
    let logs: [DailyLog]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Trends")
                .font(.headline)
                .padding(.horizontal, AppTheme.spacingLarge)

            Chart {
                ForEach(logs) { log in
                    LineMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Mood", log.generalMood),
                        series: .value("Metric", "Mood")
                    )
                    .foregroundStyle(by: .value("Metric", "Mood"))

                    LineMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Energy", log.generalEnergy),
                        series: .value("Metric", "Energy")
                    )
                    .foregroundStyle(by: .value("Metric", "Energy"))
                    
                    LineMark(
                        x: .value("Date", log.date, unit: .day),
                        y: .value("Stress", log.stressLevel * 2), // Scale stress to 1-10
                        series: .value("Metric", "Stress")
                    )
                    .foregroundStyle(by: .value("Metric", "Stress"))
                }
            }
            .chartForegroundStyleScale([
                "Mood": Color.blue,
                "Energy": Color.green,
                "Stress": Color.orange
            ])
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 5))
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day(), centered: true)
                }
            }
            .frame(height: 200)
            .padding(AppTheme.spacing)
            .appCard()
            .padding(.horizontal, AppTheme.spacingLarge)
        }
    }
}


struct StatisticsGridView: View {
    let logs: [DailyLog]
    
    private var averageMood: Double {
        let total = logs.reduce(0) { $0 + $1.generalMood }
        return Double(total) / Double(logs.count)
    }
    
    private var averageEnergy: Double {
        let total = logs.reduce(0) { $0 + $1.generalEnergy }
        return Double(total) / Double(logs.count)
    }

    private var averageStress: Double {
        let total = logs.reduce(0) { $0 + $1.stressLevel }
        return Double(total) / Double(logs.count)
    }

    private var averageSleep: Double {
        let total = logs.reduce(0) { $0 + $1.timeWokeUp.timeIntervalSince($1.timeToBed) }
        return (total / Double(logs.count)) / 3600 // In hours
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Averages")
                .font(.headline)
                .padding(.horizontal, AppTheme.spacingLarge)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.spacing) {
                StatisticCard(title: "Mood", value: String(format: "%.1f", averageMood), icon: "face.smiling", color: .blue)
                StatisticCard(title: "Energy", value: String(format: "%.1f", averageEnergy), icon: "bolt.fill", color: .green)
                StatisticCard(title: "Stress", value: String(format: "%.1f", averageStress), icon: "flame.fill", color: .orange)
                StatisticCard(title: "Sleep", value: String(format: "%.1f", averageSleep) + " hr", icon: "bed.double.fill", color: .purple)
            }
            .padding(.horizontal, AppTheme.spacingLarge)
        }
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
                .font(AppTheme.Typography.captionBold)
                .foregroundColor(AppTheme.text)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(AppTheme.spacing)
        .appCard()
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 