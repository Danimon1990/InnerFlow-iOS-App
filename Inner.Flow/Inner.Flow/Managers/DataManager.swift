//
//  DataManager.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class DataManager: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var dailyLogs: [DailyLog] = []
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Daily Logs
    
    func fetchDailyLogs(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("daily_logs")
                .order(by: "date", descending: true)
                .limit(to: 30)
                .getDocuments()
            
            dailyLogs = snapshot.documents.compactMap { document in
                let data = document.data()
                var log = DailyLog(
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    mood: data["mood"] as? String ?? "",
                    notes: data["notes"] as? String ?? "",
                    moodScore: data["moodScore"] as? Int ?? 5,
                    activities: data["activities"] as? [String] ?? []
                )
                log.id = document.documentID
                return log
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func saveDailyLog(_ log: DailyLog, for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let documentRef = db.collection("users")
                .document(userId)
                .collection("daily_logs")
                .document(log.date.formatted(date: .numeric, time: .omitted))
            
            let data: [String: Any] = [
                "date": Timestamp(date: log.date),
                "mood": log.mood,
                "notes": log.notes,
                "moodScore": log.moodScore,
                "activities": log.activities,
                "createdAt": Timestamp(date: log.createdAt),
                "updatedAt": Timestamp(date: log.updatedAt)
            ]
            
            try await documentRef.setData(data)
            
            // Refresh the logs
            await fetchDailyLogs(for: userId)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func getDailyLog(for date: Date, userId: String) async -> DailyLog? {
        do {
            let documentRef = db.collection("users")
                .document(userId)
                .collection("daily_logs")
                .document(date.formatted(date: .numeric, time: .omitted))
            
            let document = try await documentRef.getDocument()
            guard let data = document.data() else { return nil }
            
            var log = DailyLog(
                date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                mood: data["mood"] as? String ?? "",
                notes: data["notes"] as? String ?? "",
                moodScore: data["moodScore"] as? Int ?? 5,
                activities: data["activities"] as? [String] ?? []
            )
            log.id = document.documentID
            return log
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - User Profile
    
    func fetchUserProfile(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            guard let data = document.data() else {
                isLoading = false
                return
            }
            
            let notificationData = data["notificationSettings"] as? [String: Any] ?? [:]
            let notificationSettings = NotificationSettings(
                dailyReminder: notificationData["dailyReminder"] as? Bool ?? true,
                weeklyReport: notificationData["weeklyReport"] as? Bool ?? true
            )
            
            var profile = UserProfile(
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                notificationSettings: notificationSettings
            )
            profile.id = document.documentID
            userProfile = profile
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func updateUserProfile(_ profile: UserProfile, for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data: [String: Any] = [
                "name": profile.name,
                "email": profile.email,
                "createdAt": Timestamp(date: profile.createdAt),
                "notificationSettings": [
                    "dailyReminder": profile.notificationSettings.dailyReminder,
                    "weeklyReport": profile.notificationSettings.weeklyReport
                ]
            ]
            
            try await db.collection("users").document(userId).setData(data)
            userProfile = profile
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Analytics
    
    func getMoodTrends(for userId: String, days: Int = 7) async -> [DailyLog] {
        do {
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("daily_logs")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
                .order(by: "date", descending: false)
                .getDocuments()
            
            return snapshot.documents.compactMap { document in
                let data = document.data()
                var log = DailyLog(
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    mood: data["mood"] as? String ?? "",
                    notes: data["notes"] as? String ?? "",
                    moodScore: data["moodScore"] as? Int ?? 5,
                    activities: data["activities"] as? [String] ?? []
                )
                log.id = document.documentID
                return log
            }
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    func getAverageMoodScore(for userId: String, days: Int = 7) async -> Double {
        let logs = await getMoodTrends(for: userId, days: days)
        guard !logs.isEmpty else { return 0 }
        
        let totalScore = logs.reduce(0) { $0 + $1.moodScore }
        return Double(totalScore) / Double(logs.count)
    }
} 
