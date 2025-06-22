//
//  AppTheme.swift
//  Inner.Flow
//
//  Created by Daniel Moreno on 6/21/25.
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let primary = Color(hex: "8A7CFF")
    static let secondary = Color(hex: "B8B0FF")
    static let tertiary = Color(hex: "E0DDFF")
    static let background = Color(hex: "F8F7FF")
    static let text = Color(hex: "2D2D2D")
    static let textSecondary = Color(hex: "6B6B6B")
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FF9800")
    static let error = Color(hex: "F44336")
    
    // MARK: - Spacing
    static let spacing: CGFloat = 16
    static let spacingSmall: CGFloat = 8
    static let spacingLarge: CGFloat = 24
    static let spacingExtraLarge: CGFloat = 32
    
    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 12
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusLarge: CGFloat = 16
    
    // MARK: - Shadows
    static let shadowRadius: CGFloat = 8
    static let shadowOpacity: Float = 0.1
    static let shadowOffset = CGSize(width: 0, height: 2)
    
    // MARK: - Typography
    struct Typography {
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let caption = Font.system(size: 14, weight: .regular, design: .rounded)
        static let captionBold = Font.system(size: 14, weight: .semibold, design: .rounded)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    func appCard() -> some View {
        self
            .background(Color.white)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(
                color: AppTheme.primary.opacity(0.1),
                radius: AppTheme.shadowRadius,
                x: AppTheme.shadowOffset.width,
                y: AppTheme.shadowOffset.height
            )
    }
    
    func appButton() -> some View {
        self
            .background(AppTheme.primary)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(
                color: AppTheme.primary.opacity(0.3),
                radius: AppTheme.shadowRadius,
                x: AppTheme.shadowOffset.width,
                y: AppTheme.shadowOffset.height
            )
    }
} 