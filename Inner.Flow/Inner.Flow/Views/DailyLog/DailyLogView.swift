//
//  DailyLogView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct DailyLogView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showNewLog = false
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                if dataManager.dailyLogs.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppTheme.spacing) {
                            ForEach(dataManager.dailyLogs) { log in
                                DailyLogCard(log: log)
                                    .padding(.horizontal, AppTheme.spacingLarge)
                            }
                        }
                        .padding(.vertical, AppTheme.spacingLarge)
                    }
                }
            }
            .navigationTitle("Daily Logs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showNewLog = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.primary)
                    }
                }
            }
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

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: AppTheme.spacingLarge) {
            Image(systemName: "book.closed")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.primary)
            
            VStack(spacing: AppTheme.spacing) {
                Text("No Daily Logs Yet")
                    .font(AppTheme.Typography.title2)
                    .foregroundColor(AppTheme.text)
                
                Text("Start tracking your daily mood and reflections to see your progress over time")
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppTheme.spacingExtraLarge)
    }
}

struct DailyLogCard: View {
    let log: DailyLog
    @State private var showDetails = false
    
    var body: some View {
        Button(action: { showDetails = true }) {
            HStack(spacing: AppTheme.spacing) {
                // Mood Emoji
                Text(log.mood)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    HStack {
                        Text(log.date.formatted(date: .abbreviated, time: .omitted))
                            .font(AppTheme.Typography.bodyBold)
                            .foregroundColor(AppTheme.text)
                        
                        Spacer()
                        
                        Text("\(log.moodScore)/10")
                            .font(AppTheme.Typography.captionBold)
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    if !log.notes.isEmpty {
                        Text(log.notes)
                            .font(AppTheme.Typography.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    if !log.activities.isEmpty {
                        HStack {
                            ForEach(log.activities.prefix(3), id: \.self) { activity in
                                Text(activity)
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.primary)
                                    .padding(.horizontal, AppTheme.spacingSmall)
                                    .padding(.vertical, 4)
                                    .background(AppTheme.tertiary)
                                    .cornerRadius(AppTheme.cornerRadiusSmall)
                            }
                            
                            if log.activities.count > 3 {
                                Text("+\(log.activities.count - 3)")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(AppTheme.spacing)
            .appCard()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            DailyLogDetailView(log: log)
        }
    }
}

#Preview {
    DailyLogView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 