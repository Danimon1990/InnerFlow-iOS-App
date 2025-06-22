//
//  DailyLog.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import Foundation
import FirebaseFirestore

struct DailyLog: Codable, Identifiable {
    var id: String?
    var date: Date
    
    // Mood
    var morningMood: Int // 1-10
    var generalMood: Int // 1-10
    
    // Energy
    var morningEnergy: Int // 1-10
    var generalEnergy: Int // 1-10
    
    // Sleep
    var timeToBed: Date
    var timeWokeUp: Date
    
    // Stress
    var stressLevel: Int // 1-5
    
    // Target Symptom
    var targetSymptom: TargetSymptomStatus
    
    // Food
    var foodBreakfast: String
    var foodSnack1: String
    var foodLunch: String
    var foodSnack2: String
    var foodDinner: String
    var foodDrinks: String
    
    // Medicines
    var medicines: String
    
    // Digestive
    var digestiveFlow: Int // 1-10
    var digestiveFlowNotes: String
    
    // Moon Cycle
    var moonCycleNotes: String
    
    // Pain
    var painLevel: Int // 1-10
    var painNotes: String
    
    // General Notes
    var notes: String
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String? = nil,
         date: Date = Date(),
         morningMood: Int = 5,
         generalMood: Int = 5,
         morningEnergy: Int = 5,
         generalEnergy: Int = 5,
         timeToBed: Date = Date(),
         timeWokeUp: Date = Date(),
         stressLevel: Int = 3,
         targetSymptom: TargetSymptomStatus = .same,
         foodBreakfast: String = "",
         foodSnack1: String = "",
         foodLunch: String = "",
         foodSnack2: String = "",
         foodDinner: String = "",
         foodDrinks: String = "",
         medicines: String = "",
         digestiveFlow: Int = 5,
         digestiveFlowNotes: String = "",
         moonCycleNotes: String = "",
         painLevel: Int = 0,
         painNotes: String = "",
         notes: String = "") {
        self.id = id
        self.date = date
        self.morningMood = morningMood
        self.generalMood = generalMood
        self.morningEnergy = morningEnergy
        self.generalEnergy = generalEnergy
        self.timeToBed = timeToBed
        self.timeWokeUp = timeWokeUp
        self.stressLevel = stressLevel
        self.targetSymptom = targetSymptom
        self.foodBreakfast = foodBreakfast
        self.foodSnack1 = foodSnack1
        self.foodLunch = foodLunch
        self.foodSnack2 = foodSnack2
        self.foodDinner = foodDinner
        self.foodDrinks = foodDrinks
        self.medicines = medicines
        self.digestiveFlow = digestiveFlow
        self.digestiveFlowNotes = digestiveFlowNotes
        self.moonCycleNotes = moonCycleNotes
        self.painLevel = painLevel
        self.painNotes = painNotes
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum TargetSymptomStatus: String, Codable, CaseIterable {
    case increased = "Increased"
    case decreased = "Decreased"
    case same = "Same"
}

enum MoodEmoji: String, CaseIterable {
    case excellent = "😄"
    case good = "🙂"
    case okay = "😐"
    case bad = "😔"
    case terrible = "😢"
    
    var description: String {
        switch self {
        case .excellent: return "Excellent"
        case .good: return "Good"
        case .okay: return "Okay"
        case .bad: return "Bad"
        case .terrible: return "Terrible"
        }
    }
    
    var score: Int {
        switch self {
        case .excellent: return 10
        case .good: return 8
        case .okay: return 6
        case .bad: return 4
        case .terrible: return 2
        }
    }
} 
