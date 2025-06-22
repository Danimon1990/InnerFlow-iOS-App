//
//  DailyLogDetailView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct DailyLogDetailView: View {
    let log: DailyLog
    
    var body: some View {
        Form {
            Section(header: Text("Date")) {
                Text(log.date.formatted(date: .long, time: .omitted))
            }
            
            Section(header: Text("Mood")) {
                DetailRow(title: "Morning Mood", value: "\(log.morningMood)/10")
                DetailRow(title: "General Mood", value: "\(log.generalMood)/10")
            }
            
            Section(header: Text("Energy")) {
                DetailRow(title: "Morning Energy", value: "\(log.morningEnergy)/10")
                DetailRow(title: "General Energy", value: "\(log.generalEnergy)/10")
            }

            Section(header: Text("Sleep")) {
                DetailRow(title: "Time in Bed", value: log.timeToBed.formatted(date: .omitted, time: .shortened))
                DetailRow(title: "Time Woke Up", value: log.timeWokeUp.formatted(date: .omitted, time: .shortened))
            }

            Section(header: Text("Stress & Symptoms")) {
                DetailRow(title: "Stress Level", value: "\(log.stressLevel)/5")
                DetailRow(title: "Target Symptom", value: log.targetSymptom.rawValue)
            }
            
            Section(header: Text("Food Intake")) {
                DetailTextView(title: "Breakfast", text: log.foodBreakfast)
                DetailTextView(title: "Snacks", text: log.foodSnack1)
                DetailTextView(title: "Lunch", text: log.foodLunch)
                DetailTextView(title: "Snacks", text: log.foodSnack2)
                DetailTextView(title: "Dinner", text: log.foodDinner)
                DetailTextView(title: "Drinks", text: log.foodDrinks)
            }
            
            Section(header: Text("Medicines, Herbs & Supplements")) {
                DetailTextView(title: "Details", text: log.medicines)
            }
            
            Section(header: Text("Digestive Flow")) {
                DetailRow(title: "Rating", value: "\(log.digestiveFlow)/10")
                DetailTextView(title: "Details", text: log.digestiveFlowNotes)
            }

            Section(header: Text("Moon Cycle")) {
                DetailTextView(title: "Notes", text: log.moonCycleNotes)
            }

            Section(header: Text("Pain")) {
                DetailRow(title: "Pain Level", value: "\(log.painLevel)/10")
                DetailTextView(title: "Details", text: log.painNotes)
            }
            
            Section(header: Text("General Notes")) {
                Text(log.notes)
            }
        }
        .navigationTitle("Log for \(log.date.formatted(date: .abbreviated, time: .omitted))")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Detail Components

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct DetailTextView: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
            if text.isEmpty {
                Text("No entry")
                    .italic()
                    .foregroundColor(.secondary)
            } else {
                Text(text)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        DailyLogDetailView(log: DailyLog(
            date: Date(),
            morningMood: 8,
            generalMood: 7,
            morningEnergy: 7,
            generalEnergy: 6,
            timeToBed: Date().addingTimeInterval(-8 * 60 * 60),
            timeWokeUp: Date(),
            stressLevel: 2,
            targetSymptom: .decreased,
            foodBreakfast: "Oatmeal and berries",
            foodLunch: "Salad with chicken",
            foodDinner: "Salmon and vegetables",
            medicines: "Vitamin D",
            digestiveFlow: 8,
            painLevel: 1,
            notes: "A pretty good day overall. Felt a little tired in the afternoon but pushed through. The salad for lunch was a great choice."
        ))
    }
} 