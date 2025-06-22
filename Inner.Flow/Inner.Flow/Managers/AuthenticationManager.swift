//
//  AuthenticationManager.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        user = auth.currentUser
        isAuthenticated = user != nil
        
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
            
            if let user = user {
                Task {
                    await self?.fetchUserProfile(for: user.uid)
                }
            } else {
                self?.userProfile = nil
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            auth.removeStateDidChangeListener(listener)
        }
    }
    
    func signUp(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = result.user
            
            // Create user profile in Firestore
            let profile = UserProfile(
                name: name,
                email: email,
                createdAt: Date(),
                notificationSettings: NotificationSettings(
                    dailyReminder: true,
                    weeklyReport: true
                )
            )
            
            let data: [String: Any] = [
                "name": profile.name,
                "email": profile.email,
                "createdAt": Timestamp(date: profile.createdAt),
                "notificationSettings": [
                    "dailyReminder": profile.notificationSettings.dailyReminder,
                    "weeklyReport": profile.notificationSettings.weeklyReport
                ]
            ]
            
            try await db.collection("users").document(user.uid).setData(data)
            self.userProfile = profile
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await fetchUserProfile(for: result.user.uid)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            userProfile = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUserProfile(for userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            guard let data = document.data() else { return }
            
            let notificationData = data["notificationSettings"] as? [String: Any] ?? [:]
            let notificationSettings = NotificationSettings(
                dailyReminder: notificationData["dailyReminder"] as? Bool ?? true,
                weeklyReport: notificationData["weeklyReport"] as? Bool ?? true
            )
            
            var userProfile = UserProfile(
                name: data["name"] as? String ?? "",
                email: data["email"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                notificationSettings: notificationSettings
            )
            userProfile.id = document.documentID
            self.userProfile = userProfile
        } catch {
            errorMessage = error.localizedDescription
        }
    }
} 