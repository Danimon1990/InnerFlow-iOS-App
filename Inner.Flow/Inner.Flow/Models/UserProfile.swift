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
    let name: String
    let email: String
    let createdAt: Date
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
