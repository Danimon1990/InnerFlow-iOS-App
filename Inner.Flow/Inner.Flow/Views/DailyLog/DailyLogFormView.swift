//
//  DailyLogFormView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct DailyLogFormView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMood: MoodEmoji = .okay
    @State private var notes = ""
    @State private var selectedActivities: Set<String> = []
    @State private var customActivity = ""
    @State private var showActivitySheet = false
    @State private var isLoading = false
    
    private let availableActivities = [
        "Exercise", "Reading", "Meditation", "Work", "Social", 
        "Family", "Hobbies", "Rest", "Learning", "Creative"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Date Header
                        VStack(spacing: AppTheme.spacingSmall) {
                            Text(Date().formatted(date: .complete, time: .omitted))
                                .font(AppTheme.Typography.title3)
                                .foregroundColor(AppTheme.text)
                            
                            Text("How are you feeling today?")
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, AppTheme.spacingLarge)
                        
                        // Mood Selection
                        VStack(spacing: AppTheme.spacing) {
                            Text("Select Your Mood")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.text)
                            
                            HStack(spacing: AppTheme.spacing) {
                                ForEach(MoodEmoji.allCases, id: \.self) { mood in
                                    Button(action: { selectedMood = mood }) {
                                        VStack(spacing: AppTheme.spacingSmall) {
                                            Text(mood.rawValue)
                                                .font(.system(size: 40))
                                                .opacity(selectedMood == mood ? 1.0 : 0.6)
                                            
                                            Text(mood.description)
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(selectedMood == mood ? AppTheme.primary : AppTheme.textSecondary)
                                        }
                                        .padding(AppTheme.spacing)
                                        .background(
                                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                                .fill(selectedMood == mood ? AppTheme.tertiary : Color.clear)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Notes Section
                        VStack(spacing: AppTheme.spacing) {
                            Text("Reflections & Notes")
                                .font(AppTheme.Typography.headline)
                                .foregroundColor(AppTheme.text)
                            
                            TextEditor(text: $notes)
                                .frame(minHeight: 120)
                                .padding(AppTheme.spacing)
                                .background(Color.white)
                                .cornerRadius(AppTheme.cornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                        .stroke(AppTheme.secondary, lineWidth: 1)
                                )
                        }
                        .padding(AppTheme.spacingLarge)
                        .appCard()
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Activities Section
                        VStack(spacing: AppTheme.spacing) {
                            HStack {
                                Text("Activities")
                                    .font(AppTheme.Typography.headline)
                                    .foregroundColor(AppTheme.text)
                                
                                Spacer()
                                
                                Button("Add") {
                                    showActivitySheet = true
                                }
                                .font(AppTheme.Typography.body)
                                .foregroundColor(AppTheme.primary)
                            }
                            
                            if selectedActivities.isEmpty {
                                Text("No activities selected")
                                    .font(AppTheme.Typography.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: AppTheme.spacingSmall) {
                                    ForEach(Array(selectedActivities), id: \.self) { activity in
                                        HStack {
                                            Text(activity)
                                                .font(AppTheme.Typography.caption)
                                                .foregroundColor(AppTheme.primary)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                selectedActivities.remove(activity)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
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
                        .padding(.horizontal, AppTheme.spacingLarge)
                        
                        // Save Button
                        Button(action: saveLog) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Save Daily Log")
                                        .font(AppTheme.Typography.bodyBold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                        }
                        .appButton()
                        .disabled(isLoading)
                        .padding(.horizontal, AppTheme.spacingLarge)
                        .padding(.bottom, AppTheme.spacingLarge)
                    }
                }
            }
            .navigationTitle("New Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primary)
                }
            }
        }
        .sheet(isPresented: $showActivitySheet) {
            ActivitySelectionView(
                selectedActivities: $selectedActivities,
                availableActivities: availableActivities
            )
        }
    }
    
    private func saveLog() {
        guard let userId = authManager.user?.uid else { return }
        
        isLoading = true
        
        let log = DailyLog(
            mood: selectedMood.rawValue,
            notes: notes,
            moodScore: selectedMood.score,
            activities: Array(selectedActivities)
        )
        
        Task {
            await dataManager.saveDailyLog(log, for: userId)
            isLoading = false
            dismiss()
        }
    }
}

struct ActivitySelectionView: View {
    @Binding var selectedActivities: Set<String>
    let availableActivities: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var customActivity = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppTheme.spacingLarge) {
                    // Custom Activity
                    VStack(spacing: AppTheme.spacing) {
                        Text("Add Custom Activity")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.text)
                        
                        HStack {
                            TextField("Enter custom activity", text: $customActivity)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button("Add") {
                                if !customActivity.isEmpty {
                                    selectedActivities.insert(customActivity)
                                    customActivity = ""
                                }
                            }
                            .appButton()
                            .frame(width: 60)
                            .disabled(customActivity.isEmpty)
                        }
                    }
                    .padding(AppTheme.spacingLarge)
                    .appCard()
                    .padding(.horizontal, AppTheme.spacingLarge)
                    
                    // Available Activities
                    VStack(spacing: AppTheme.spacing) {
                        Text("Common Activities")
                            .font(AppTheme.Typography.headline)
                            .foregroundColor(AppTheme.text)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppTheme.spacing) {
                            ForEach(availableActivities, id: \.self) { activity in
                                Button(action: {
                                    if selectedActivities.contains(activity) {
                                        selectedActivities.remove(activity)
                                    } else {
                                        selectedActivities.insert(activity)
                                    }
                                }) {
                                    HStack {
                                        Text(activity)
                                            .font(AppTheme.Typography.body)
                                            .foregroundColor(selectedActivities.contains(activity) ? .white : AppTheme.text)
                                        
                                        Spacer()
                                        
                                        if selectedActivities.contains(activity) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(AppTheme.spacing)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                            .fill(selectedActivities.contains(activity) ? AppTheme.primary : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                            .stroke(AppTheme.primary, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(AppTheme.spacingLarge)
                    .appCard()
                    .padding(.horizontal, AppTheme.spacingLarge)
                    
                    Spacer()
                }
            }
            .navigationTitle("Select Activities")
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
    DailyLogFormView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 