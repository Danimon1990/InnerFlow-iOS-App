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
    
    // State for all the new DailyLog fields
    @State private var date = Date()
    @State private var morningMood: Double = 5
    @State private var generalMood: Double = 5
    @State private var morningEnergy: Double = 5
    @State private var generalEnergy: Double = 5
    @State private var timeToBed = Date()
    @State private var timeWokeUp = Date()
    @State private var stressLevel: Double = 3
    @State private var targetSymptom: TargetSymptomStatus = .same
    @State private var foodBreakfast = ""
    @State private var foodSnack1 = ""
    @State private var foodLunch = ""
    @State private var foodSnack2 = ""
    @State private var foodDinner = ""
    @State private var foodDrinks = ""
    @State private var medicines = ""
    @State private var digestiveFlow: Double = 5
    @State private var digestiveFlowNotes = ""
    @State private var moonCycleNotes = ""
    @State private var painLevel: Double = 0
    @State private var painNotes = ""
    @State private var notes = ""
    
    @State private var isLoading = false

    // Use the settings from the authenticated user's profile
    private var settings: TrackingSettings {
        authManager.userProfile?.trackingSettings ?? TrackingSettings()
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Date")) {
                        DatePicker("Log Date", selection: $date, displayedComponents: .date)
                    }

                    if settings.trackMood {
                        CollapsibleSection(title: "Mood") {
                            RatingSlider(value: $morningMood, label: "Morning Mood")
                            RatingSlider(value: $generalMood, label: "General Mood")
                        }
                    }

                    if settings.trackEnergy {
                        CollapsibleSection(title: "Energy") {
                            RatingSlider(value: $morningEnergy, label: "Morning Energy")
                            RatingSlider(value: $generalEnergy, label: "General Energy")
                        }
                    }
                    
                    if settings.trackSleep {
                        CollapsibleSection(title: "Sleep") {
                            DatePicker("Time Went to Bed", selection: $timeToBed, displayedComponents: .hourAndMinute)
                            DatePicker("Time Woke Up", selection: $timeWokeUp, displayedComponents: .hourAndMinute)
                        }
                    }

                    if settings.trackStress {
                        CollapsibleSection(title: "Stress Level") {
                            RatingSlider(value: $stressLevel, label: "Stress", range: 1...5)
                        }
                    }
                    
                    if settings.trackSymptoms {
                        CollapsibleSection(title: "Target Symptom") {
                            Picker("Status", selection: $targetSymptom) {
                                ForEach(TargetSymptomStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }

                    if settings.trackFood {
                        CollapsibleSection(title: "Food Intake") {
                            TitledTextField(title: "Breakfast", text: $foodBreakfast)
                            TitledTextField(title: "Snacks", text: $foodSnack1)
                            TitledTextField(title: "Lunch", text: $foodLunch)
                            TitledTextField(title: "Snacks", text: $foodSnack2)
                            TitledTextField(title: "Dinner", text: $foodDinner)
                            TitledTextField(title: "Drinks", text: $foodDrinks)
                        }
                    }

                    if settings.trackMedicines {
                        CollapsibleSection(title: "Medicines, Herbs & Supplements") {
                            TitledTextField(title: "Details", text: $medicines, placeholder: "List items and dosages")
                        }
                    }
                    
                    if settings.trackDigestion {
                        CollapsibleSection(title: "Digestive Flow") {
                            RatingSlider(value: $digestiveFlow, label: "Rating")
                            TitledTextField(title: "Details", text: $digestiveFlowNotes)
                        }
                    }

                    if settings.trackMoonCycle {
                        CollapsibleSection(title: "Moon Cycle") {
                             TitledTextField(title: "Hormonal, Physical, or Menstrual Changes", text: $moonCycleNotes)
                        }
                    }
                    
                    if settings.trackPain {
                        CollapsibleSection(title: "Pain") {
                            RatingSlider(value: $painLevel, label: "Pain Level")
                             TitledTextField(title: "Details", text: $painNotes)
                        }
                    }

                    if settings.trackNotes {
                        CollapsibleSection(title: "General Notes") {
                            TextEditor(text: $notes)
                                .frame(minHeight: 150)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Daily Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveLog) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
    
    private func saveLog() {
        guard let userId = authManager.user?.uid else { return }
        
        isLoading = true
        
        let log = DailyLog(
            date: date,
            morningMood: Int(morningMood),
            generalMood: Int(generalMood),
            morningEnergy: Int(morningEnergy),
            generalEnergy: Int(generalEnergy),
            timeToBed: timeToBed,
            timeWokeUp: timeWokeUp,
            stressLevel: Int(stressLevel),
            targetSymptom: targetSymptom,
            foodBreakfast: foodBreakfast,
            foodSnack1: foodSnack1,
            foodLunch: foodLunch,
            foodSnack2: foodSnack2,
            foodDinner: foodDinner,
            foodDrinks: foodDrinks,
            medicines: medicines,
            digestiveFlow: Int(digestiveFlow),
            digestiveFlowNotes: digestiveFlowNotes,
            moonCycleNotes: moonCycleNotes,
            painLevel: Int(painLevel),
            painNotes: painNotes,
            notes: notes
        )
        
        Task {
            await dataManager.saveDailyLog(log, for: userId)
            isLoading = false
            dismiss()
        }
    }
}


// MARK: - Reusable Components

struct CollapsibleSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        DisclosureGroup(title) {
            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                content
            }
            .padding(.vertical, AppTheme.spacing)
        }
    }
}

struct RatingSlider: View {
    @Binding var value: Double
    let label: String
    var range: ClosedRange<Double> = 1...10
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            Text(label)
                .font(AppTheme.Typography.body)
            Slider(value: $value, in: range, step: 1)
            Text("Rating: \(Int(value))")
                .font(AppTheme.Typography.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

struct TitledTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            Text(title)
                .font(AppTheme.Typography.body)
            TextField(placeholder, text: $text)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

// TODO: This should be moved to the UserProfile model and populated from Firestore
// DELETE THE STRUCT BELOW
/*
struct TrackingSettings {
    var trackMood: Bool = true
    var trackEnergy: Bool = true
    var trackSleep: Bool = true
    var trackStress: Bool = true
    var trackSymptoms: Bool = true
    var trackFood: Bool = true
    var trackMedicines: Bool = true
    var trackDigestion: Bool = true
    var trackMoonCycle: Bool = true
    var trackPain: Bool = true
    var trackNotes: Bool = true
}
*/

#Preview {
    DailyLogFormView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 