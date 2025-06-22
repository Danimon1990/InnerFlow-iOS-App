//
//  DailyLogDetailView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct DailyLogDetailView: View {
    let log: DailyLog
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Header with Date and Mood
                        VStack(spacing: AppTheme.spacing) {
                            Text(log.date.formatted(date: .complete, time: .omitted))
                                .font(AppTheme.Typography.title2)
                                .foregroundColor(AppTheme.text)
                            
                            HStack(spacing: AppTheme.spacing) {
                                Text(log.mood)
                                    .font(.system(size: 60))
                                
                                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                                    Text("Mood Score")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text("\(log.moodScore)/10")
                                        .font(AppTheme.Typography.title3)
                                        .foregroundColor(AppTheme.primary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Notes Section
                        if !log.notes.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                                Text("Reflections & Notes")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.text)
                                
                                Text(log.notes)
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(AppTheme.spacingLarge)
                            .appCard()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        }
                        
                        // Activities Section
                        if !log.activities.isEmpty {
                            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                                Text("Activities")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.text)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: AppTheme.spacingSmall) {
                                    ForEach(log.activities, id: \.self) { activity in
                                        Text(activity)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(AppTheme.primary)
                                            .padding(.horizontal, AppTheme.spacing)
                                            .padding(.vertical, AppTheme.spacingSmall)
                                            .background(AppTheme.tertiary)
                                            .cornerRadius(AppTheme.cornerRadiusSmall)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(AppTheme.spacingLarge)
                            .appCard()
                            .padding(.horizontal, AppTheme.spacingLarge)
                        }
                        
                        // Metadata
                        VStack(alignment: .leading, spacing: AppTheme.spacing) {
                            Text("Entry Details")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.text)
                            
                            VStack(spacing: AppTheme.spacingSmall) {
                                HStack {
                                    Text("Created")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text(log.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.text)
                                }
                                
                                HStack {
                                    Text("Last Updated")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text(log.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.text)
                                }
                            }
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        Spacer(minLength: AppTheme.spacingExtraLarge)
                    }
                }
            }
            .navigationTitle("Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
    }
}

#Preview {
    DailyLogDetailView(log: DailyLog(
        mood: "😄",
        notes: "Today was a great day! I felt productive and happy.",
        moodScore: 9,
        activities: ["Exercise", "Work", "Reading"]
    ))
} 