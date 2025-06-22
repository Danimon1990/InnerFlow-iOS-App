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
    let date: Date
    let mood: String
    let notes: String
    let moodScore: Int // 1-10 scale
    let activities: [String]
    let createdAt: Date
    let updatedAt: Date
    
    init(date: Date = Date(), mood: String, notes: String, moodScore: Int, activities: [String] = []) {
        self.date = date
        self.mood = mood
        self.notes = notes
        self.moodScore = max(1, min(10, moodScore)) // Ensure score is between 1-10
        self.activities = activities
        self.createdAt = Date()
        self.updatedAt = Date()
    }
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
