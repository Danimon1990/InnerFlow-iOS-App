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
    let notificationSettings: NotificationSettings
    
    init(name: String, email: String, createdAt: Date = Date(), notificationSettings: NotificationSettings = NotificationSettings()) {
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.notificationSettings = notificationSettings
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
