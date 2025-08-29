//
//  ProfileEditView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    // States for each editable field
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var age: String = ""
    @State private var gender: Gender = .preferNotToSay
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var medicalCondition: String = ""
    @State private var medicines: String = ""
    @State private var familyHistory: String = ""
    @State private var goal: String = ""
    @State private var bloodType: BloodType = .unknown
    
    @State private var isLoading = false
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $name)
                    TextField("Last Name", text: $lastName)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                }
                
                Section(header: Text("Physical Attributes")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Medical Information")) {
                    TextField("Medical Conditions", text: $medicalCondition, axis: .vertical)
                        .lineLimit(3...)
                    TextField("Medicines, Herbs, Supplements", text: $medicines, axis: .vertical)
                        .lineLimit(3...)
                    Picker("Blood Type", selection: $bloodType) {
                        ForEach(BloodType.allCases) { bloodType in
                            Text(bloodType.rawValue).tag(bloodType)
                        }
                    }
                    TextField("Family History", text: $familyHistory, axis: .vertical)
                        .lineLimit(3...)
                    TextField("Health Goal", text: $goal, axis: .vertical)
                        .lineLimit(3...)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveProfile)
                        .disabled(isLoading)
                }
            }
            .onAppear(perform: loadCurrentProfile)
            .overlay {
                if isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Saving...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func loadCurrentProfile() {
        guard let profile = authManager.userProfile else { return }
        name = profile.name
        lastName = profile.lastName ?? ""
        age = profile.age.map(String.init) ?? ""
        gender = profile.gender ?? .preferNotToSay
        weight = profile.weight.map { numberFormatter.string(from: NSNumber(value: $0)) ?? "" } ?? ""
        height = profile.height.map { numberFormatter.string(from: NSNumber(value: $0)) ?? "" } ?? ""
        medicalCondition = profile.medicalCondition ?? ""
        medicines = profile.medicines ?? ""
        familyHistory = profile.familyHistory ?? ""
        goal = profile.goal ?? ""
        bloodType = profile.bloodType ?? .unknown
    }
    
    private func saveProfile() {
        guard let userId = authManager.user?.uid,
              var updatedProfile = authManager.userProfile else { return }
        
        isLoading = true
        
        // Update the profile object with new values from the form
        updatedProfile.name = name
        updatedProfile.lastName = lastName.isEmpty ? nil : lastName
        updatedProfile.age = Int(age)
        updatedProfile.gender = gender
        updatedProfile.weight = Double(weight)
        updatedProfile.height = Double(height)
        updatedProfile.medicalCondition = medicalCondition.isEmpty ? nil : medicalCondition
        updatedProfile.medicines = medicines.isEmpty ? nil : medicines
        updatedProfile.familyHistory = familyHistory.isEmpty ? nil : familyHistory
        updatedProfile.goal = goal.isEmpty ? nil : goal
        updatedProfile.bloodType = bloodType == .unknown ? nil : bloodType
        
        Task {
            await dataManager.updateUserProfile(updatedProfile, for: userId)
            // The authManager's profile will be updated by the DataManager's call
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    ProfileEditView()
        .environmentObject(DataManager())
        .environmentObject(AuthenticationManager())
} 