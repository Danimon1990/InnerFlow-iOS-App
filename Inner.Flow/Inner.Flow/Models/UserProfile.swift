//
//  UserProfile.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    var id: String?
    // Basic Info
    var name: String // First Name
    var lastName: String?
    let email: String
    let createdAt: Date
    
    // Demographics
    var age: Int?
    var gender: Gender?
    var weight: Double? // in kg or lbs, user preference can be a future feature
    var height: Double? // in cm or inches
    
    // Health Info
    var medicalCondition: String?
    var medicines: String?
    
    // App Settings
    var notificationSettings: NotificationSettings
    var trackingSettings: TrackingSettings
    
    init(name: String, email: String, createdAt: Date = Date(), notificationSettings: NotificationSettings = NotificationSettings(), trackingSettings: TrackingSettings = TrackingSettings()) {
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.notificationSettings = notificationSettings
        self.trackingSettings = trackingSettings
    }
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-Binary"
    case preferNotToSay = "Prefer Not to Say"
}

struct NotificationSettings: Codable {
    var dailyReminder: Bool
    var weeklyReport: Bool
    
    init(dailyReminder: Bool = true, weeklyReport: Bool = true) {
        self.dailyReminder = dailyReminder
        self.weeklyReport = weeklyReport
    }
}

struct TrackingSettings: Codable {
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
 