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
    
    private func dailyLogsCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("daily_logs")
    }
    
    // MARK: - Daily Logs
    
    func fetchDailyLogs(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await dailyLogsCollection(for: userId)
                .order(by: "date", descending: true)
                .limit(to: 30)
                .getDocuments()
            
            self.dailyLogs = snapshot.documents.compactMap { document -> DailyLog? in
                let data = document.data()
                var log = DailyLog(
                    date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                    morningMood: data["morningMood"] as? Int ?? 5,
                    generalMood: data["generalMood"] as? Int ?? 5,
                    morningEnergy: data["morningEnergy"] as? Int ?? 5,
                    generalEnergy: data["generalEnergy"] as? Int ?? 5,
                    timeToBed: (data["timeToBed"] as? Timestamp)?.dateValue() ?? Date(),
                    timeWokeUp: (data["timeWokeUp"] as? Timestamp)?.dateValue() ?? Date(),
                    stressLevel: data["stressLevel"] as? Int ?? 3,
                    targetSymptom: TargetSymptomStatus(rawValue: data["targetSymptom"] as? String ?? "same") ?? .same,
                    foodBreakfast: data["foodBreakfast"] as? String ?? "",
                    foodSnack1: data["foodSnack1"] as? String ?? "",
                    foodLunch: data["foodLunch"] as? String ?? "",
                    foodSnack2: data["foodSnack2"] as? String ?? "",
                    foodDinner: data["foodDinner"] as? String ?? "",
                    foodDrinks: data["foodDrinks"] as? String ?? "",
                    medicines: data["medicines"] as? String ?? "",
                    digestiveFlow: data["digestiveFlow"] as? Int ?? 5,
                    digestiveFlowNotes: data["digestiveFlowNotes"] as? String ?? "",
                    moonCycleNotes: data["moonCycleNotes"] as? String ?? "",
                    painLevel: data["painLevel"] as? Int ?? 0,
                    painNotes: data["painNotes"] as? String ?? "",
                    notes: data["notes"] as? String ?? ""
                )
                log.id = document.documentID
                return log
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func saveDailyLog(_ log: DailyLog, for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            var logToSave = log
            let documentRef: DocumentReference
            
            if let id = log.id {
                documentRef = dailyLogsCollection(for: userId).document(id)
                logToSave.updatedAt = Date()
            } else {
                documentRef = dailyLogsCollection(for: userId).document()
                logToSave.id = documentRef.documentID
            }
            
            let data: [String: Any] = [
                "id": logToSave.id!,
                "date": Timestamp(date: logToSave.date),
                "morningMood": logToSave.morningMood,
                "generalMood": logToSave.generalMood,
                "morningEnergy": logToSave.morningEnergy,
                "generalEnergy": logToSave.generalEnergy,
                "timeToBed": Timestamp(date: logToSave.timeToBed),
                "timeWokeUp": Timestamp(date: logToSave.timeWokeUp),
                "stressLevel": logToSave.stressLevel,
                "targetSymptom": logToSave.targetSymptom.rawValue,
                "foodBreakfast": logToSave.foodBreakfast,
                "foodSnack1": logToSave.foodSnack1,
                "foodLunch": logToSave.foodLunch,
                "foodSnack2": logToSave.foodSnack2,
                "foodDinner": logToSave.foodDinner,
                "foodDrinks": logToSave.foodDrinks,
                "medicines": logToSave.medicines,
                "digestiveFlow": logToSave.digestiveFlow,
                "digestiveFlowNotes": logToSave.digestiveFlowNotes,
                "moonCycleNotes": logToSave.moonCycleNotes,
                "painLevel": logToSave.painLevel,
                "painNotes": logToSave.painNotes,
                "notes": logToSave.notes,
                "createdAt": Timestamp(date: logToSave.createdAt),
                "updatedAt": Timestamp(date: logToSave.updatedAt)
            ]
            
            try await documentRef.setData(data, merge: true)
            
            await fetchDailyLogs(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - User Profile
    
    func fetchUserProfile(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            guard let data = document.data() else {
                errorMessage = "User profile data is empty."
                isLoading = false
                return
            }
            
            let notificationData = data["notificationSettings"] as? [String: Any] ?? [:]
            let notificationSettings = NotificationSettings(
                dailyReminder: notificationData["dailyReminder"] as? Bool ?? true,
                weeklyReport: notificationData["weeklyReport"] as? Bool ?? true
            )

            let trackingData = data["trackingSettings"] as? [String: Any] ?? [:]
            let trackingSettings = TrackingSettings(
                trackMood: trackingData["trackMood"] as? Bool ?? true,
                trackEnergy: trackingData["trackEnergy"] as? Bool ?? true,
                trackSleep: trackingData["trackSleep"] as? Bool ?? true,
                trackStress: trackingData["trackStress"] as? Bool ?? true,
                trackSymptoms: trackingData["trackSymptoms"] as? Bool ?? true,
                trackFood: trackingData["trackFood"] as? Bool ?? true,
                trackMedicines: trackingData["trackMedicines"] as? Bool ?? true,
                trackDigestion: trackingData["trackDigestion"] as? Bool ?? true,
                trackMoonCycle: trackingData["trackMoonCycle"] as? Bool ?? true,
                trackPain: trackingData["trackPain"] as? Bool ?? true,
                trackNotes: trackingData["trackNotes"] as? Bool ?? true
            )
            
            var profile = UserProfile(
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                notificationSettings: notificationSettings,
                trackingSettings: trackingSettings
            )
            profile.id = document.documentID
            self.userProfile = profile
            
        } catch {
            errorMessage = "Could not load user profile: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateUserProfile(_ profile: UserProfile, for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let trackingSettingsData: [String: Any] = [
                "trackMood": profile.trackingSettings.trackMood,
                "trackEnergy": profile.trackingSettings.trackEnergy,
                "trackSleep": profile.trackingSettings.trackSleep,
                "trackStress": profile.trackingSettings.trackStress,
                "trackSymptoms": profile.trackingSettings.trackSymptoms,
                "trackFood": profile.trackingSettings.trackFood,
                "trackMedicines": profile.trackingSettings.trackMedicines,
                "trackDigestion": profile.trackingSettings.trackDigestion,
                "trackMoonCycle": profile.trackingSettings.trackMoonCycle,
                "trackPain": profile.trackingSettings.trackPain,
                "trackNotes": profile.trackingSettings.trackNotes
            ]
            
            let data: [String: Any] = [
                "name": profile.name,
                "email": profile.email,
                "createdAt": Timestamp(date: profile.createdAt),
                "notificationSettings": [
                    "dailyReminder": profile.notificationSettings.dailyReminder,
                    "weeklyReport": profile.notificationSettings.weeklyReport
                ],
                "trackingSettings": trackingSettingsData
            ]
            
            try await db.collection("users").document(userId).setData(data, merge: true)
            self.userProfile = profile
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Analytics (Placeholder)
    
    func getMoodTrends(for userId: String, days: Int = 7) async -> [DailyLog] {
        // TODO: Re-implement with new data structure
        return []
    }
    
    func getAverageMoodScore(for userId: String, days: Int = 7) async -> Double {
        // TODO: Re-implement with new data structure
        return 0.0
    }
} 
