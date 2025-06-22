//
//  WelcomeView.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showAuthentication = false
    @State private var isSignUp = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.primary.opacity(0.1),
                    AppTheme.background
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: AppTheme.spacingExtraLarge) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: AppTheme.spacingLarge) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    VStack(spacing: AppTheme.spacing) {
                        Text("Welcome to Inner Flow")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.text)
                            .multilineTextAlignment(.center)
                        
                        Text("Track your performance and identify patterns of your health")
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.spacingLarge)
                    }
                }
                
                // Features
                VStack(spacing: AppTheme.spacingLarge) {
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Track Your Mood",
                        description: "Log your daily emotions and see patterns over time"
                    )
                    
                    FeatureRow(
                        icon: "brain.head.profile",
                        title: "Mental Health Insights",
                        description: "Understand your emotional patterns and triggers"
                    )
                    
                    FeatureRow(
                        icon: "target",
                        title: "Set Goals",
                        description: "Work towards better mental health and well-being"
                    )
                }
                .padding(.horizontal, AppTheme.spacingLarge)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: AppTheme.spacing) {
                    Button(action: {
                        isSignUp = false
                        showAuthentication = true
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Log In")
                                .font(AppTheme.Typography.bodyBold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .appButton()
                    
                    Button(action: {
                        isSignUp = true
                        showAuthentication = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Sign Up")
                                .font(AppTheme.Typography.bodyBold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .foregroundColor(AppTheme.primary)
                        .cornerRadius(AppTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .stroke(AppTheme.primary, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, AppTheme.spacingLarge)
                .padding(.bottom, AppTheme.spacingExtraLarge)
            }
        }
        .fullScreenCover(isPresented: $showAuthentication) {
            AuthenticationView(initialMode: isSignUp ? .signUp : .signIn)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: AppTheme.spacing) {
            ZStack {
                Circle()
                    .fill(AppTheme.tertiary)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                Text(title)
                    .font(AppTheme.Typography.bodyBold)
                    .foregroundColor(AppTheme.text)
                
                Text(description)
                    .font(AppTheme.Typography.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(AppTheme.spacing)
        .background(Color.white)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(
            color: AppTheme.primary.opacity(0.1),
            radius: AppTheme.shadowRadius,
            x: AppTheme.shadowOffset.width,
            y: AppTheme.shadowOffset.height
        )
    }
}

#Preview {
    WelcomeView()
} 