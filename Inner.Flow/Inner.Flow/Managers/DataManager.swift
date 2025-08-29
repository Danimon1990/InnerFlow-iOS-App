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
    @Published var analysisResults: [AnalysisResult] = []
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
        print("DataManager: Starting fetchUserProfile for userId: \(userId)")
        isLoading = true
        errorMessage = nil
        
        do {
            print("DataManager: Attempting to fetch document from Firestore...")
            let document = try await db.collection("users").document(userId).getDocument()
            print("DataManager: Document fetch completed")
            
            guard let data = document.data() else {
                print("DataManager: Document data is nil")
                errorMessage = "User profile data is empty."
                isLoading = false
                return
            }
            
            print("DataManager: Document data retrieved successfully")
            
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
            
            // Manually decode optional profile fields
            profile.id = document.documentID
            profile.lastName = data["lastName"] as? String
            profile.age = data["age"] as? Int
            if let genderString = data["gender"] as? String {
                profile.gender = Gender(rawValue: genderString)
            }
            profile.weight = data["weight"] as? Double
            profile.height = data["height"] as? Double
            profile.medicalCondition = data["medicalCondition"] as? String
            profile.medicines = data["medicines"] as? String
            profile.familyHistory = data["familyHistory"] as? String
            profile.goal = data["goal"] as? String
            if let bloodTypeString = data["bloodType"] as? String {
                profile.bloodType = BloodType(rawValue: bloodTypeString)
            }
            
            print("DataManager: User profile created successfully: \(profile.name)")
            self.userProfile = profile
            
        } catch {
            print("DataManager: Error fetching user profile: \(error.localizedDescription)")
            errorMessage = "Could not load user profile: \(error.localizedDescription)"
        }
        isLoading = false
        print("DataManager: fetchUserProfile completed")
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
            
            var data: [String: Any] = [
                "name": profile.name,
                "email": profile.email,
                "createdAt": Timestamp(date: profile.createdAt),
                "notificationSettings": [
                    "dailyReminder": profile.notificationSettings.dailyReminder,
                    "weeklyReport": profile.notificationSettings.weeklyReport
                ],
                "trackingSettings": trackingSettingsData
            ]
            
            // Manually encode optional profile fields, handling nil values
            data["lastName"] = profile.lastName
            data["age"] = profile.age
            data["gender"] = profile.gender?.rawValue
            data["weight"] = profile.weight
            data["height"] = profile.height
            data["medicalCondition"] = profile.medicalCondition
            data["medicines"] = profile.medicines
            data["familyHistory"] = profile.familyHistory
            data["goal"] = profile.goal
            data["bloodType"] = profile.bloodType?.rawValue
            
            try await db.collection("users").document(userId).setData(data, merge: true)
            self.userProfile = profile
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Analysis Results
    
    func fetchAnalysisResults(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("analysisResults")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .getDocuments()
            
            self.analysisResults = snapshot.documents.compactMap { document in
                AnalysisResult(document: document)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func getLatestAnalysis(for userId: String, type: AnalysisResult.AnalysisType) async -> AnalysisResult? {
        do {
            let snapshot = try await db.collection("analysisResults")
                .whereField("userId", isEqualTo: userId)
                .whereField("analysisType", isEqualTo: type.rawValue)
                .order(by: "createdAt", descending: true)
                .limit(to: 1)
                .getDocuments()
            
            return snapshot.documents.first.flatMap { AnalysisResult(document: $0) }
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
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
    
    // MARK: - API Calls for Manual Analysis
    
    func testAPIConnection() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "https://us-central1-inner-flow-8de4f.cloudfunctions.net/api/")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return false
            }
            
            if httpResponse.statusCode == 200 {
                let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                print("API Test successful: \(responseString)")
                isLoading = false
                return true
            } else {
                errorMessage = "API test failed with status \(httpResponse.statusCode)"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Failed to test API: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func triggerWeeklyAnalysis() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "https://us-central1-inner-flow-8de4f.cloudfunctions.net/api/weeklyAnalysis")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Success - wait a moment for the analysis to complete, then refresh
                try await Task.sleep(nanoseconds: 3_000_000_000)
                if let userId = userProfile?.id {
                    await fetchAnalysisResults(for: userId)
                }
                isLoading = false
                return true
            } else {
                let errorData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                errorMessage = errorData?["message"] as? String ?? "Analysis failed with status \(httpResponse.statusCode)"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Failed to trigger analysis: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func triggerMonthlyAnalysis() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let url = URL(string: "https://us-central1-inner-flow-8de4f.cloudfunctions.net/api/monthlyAnalysis")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return false
            }
            
            if httpResponse.statusCode == 200 {
                // Success - wait a moment for the analysis to complete, then refresh
                try await Task.sleep(nanoseconds: 3_000_000_000)
                if let userId = userProfile?.id {
                    await fetchAnalysisResults(for: userId)
                }
                isLoading = false
                return true
            } else {
                let errorData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                errorMessage = errorData?["message"] as? String ?? "Analysis failed with status \(httpResponse.statusCode)"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Failed to trigger analysis: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - Firebase Connection Test
    
    func testFirebaseConnection() async -> Bool {
        print("DataManager: Testing Firebase connection...")
        isLoading = true
        errorMessage = nil
        
        do {
            // Test basic Firestore connection
            let testDoc = try await db.collection("test").document("connection").getDocument()
            print("DataManager: Firebase connection test successful")
            isLoading = false
            return true
        } catch {
            print("DataManager: Firebase connection test failed: \(error.localizedDescription)")
            errorMessage = "Firebase connection failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
} 
 