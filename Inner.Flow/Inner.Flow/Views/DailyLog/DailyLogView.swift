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
                // Date
                VStack {
                    Text(log.date.formatted(.dateTime.month().day()))
                        .font(AppTheme.Typography.bodyBold)
                    Text(log.date.formatted(.dateTime.year()))
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.tertiary.opacity(0.5))
                .cornerRadius(AppTheme.cornerRadius)
                
                // Summary
                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    Text("Daily Summary")
                        .font(AppTheme.Typography.bodyBold)
                        .foregroundColor(AppTheme.text)
                    
                    HStack {
                        Label("Mood: \(log.generalMood)/10", systemImage: "face.smiling")
                        Spacer()
                        Label("Energy: \(log.generalEnergy)/10", systemImage: "bolt.fill")
                    }
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    
                    Label("Symptom: \(log.targetSymptom.rawValue)", systemImage: "staroflife.fill")
                        .font(AppTheme.Typography.caption)
                        .foregroundColor(AppTheme.textSecondary)

                }
                
                Spacer()
                
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