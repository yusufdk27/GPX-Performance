//
//  Theme.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI

/// Design system tokens for GPX-Performance.
/// Minimalist, high-contrast, OLED-optimized dark theme.
enum Theme {
    
    // MARK: - Colors
    
    /// Pure black background — OLED efficient.
    static let background = Color(red: 0, green: 0, blue: 0)
    
    /// Neon Orange accent — high visibility.
    static let neonOrange = Color(red: 1.0, green: 0.369, blue: 0.0) // #FF5E00
    
    /// Slate Gray — data containers.
    static let slateGray = Color(red: 0.11, green: 0.11, blue: 0.118) // #1C1C1E
    
    /// Surface Gray — elevated surfaces.
    static let surfaceGray = Color(red: 0.173, green: 0.173, blue: 0.18) // #2C2C2E
    
    /// Subtle border / separator.
    static let borderGray = Color(red: 0.22, green: 0.22, blue: 0.23) // #383839
    
    /// Primary text — white.
    static let textPrimary = Color.white
    
    /// Secondary text — dimmed.
    static let textSecondary = Color(white: 0.55)
    
    /// Tertiary text — very dimmed.
    static let textTertiary = Color(white: 0.35)
    
    /// Success green.
    static let successGreen = Color(red: 0.196, green: 0.843, blue: 0.294) // #32D74B
    
    /// Warning yellow.
    static let warningYellow = Color(red: 1.0, green: 0.839, blue: 0.039) // #FFD60A
    
    /// Danger red.
    static let dangerRed = Color(red: 1.0, green: 0.271, blue: 0.227) // #FF453A
    
    /// Cyan for descent phases.
    static let cyan = Color(red: 0.0, green: 0.8, blue: 0.9)
    
    // MARK: - Gradients
    
    /// Neon orange gradient for CTA buttons.
    static let orangeGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.45, blue: 0.0),
            Color(red: 1.0, green: 0.3, blue: 0.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Climb phase gradient (orange → red).
    static let climbGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.45, blue: 0.0),
            Color(red: 0.9, green: 0.15, blue: 0.1)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Descent phase gradient (cyan → blue).
    static let descentGradient = LinearGradient(
        colors: [
            Color(red: 0.0, green: 0.8, blue: 0.9),
            Color(red: 0.1, green: 0.4, blue: 0.9)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Flat phase gradient (green → teal).
    static let flatGradient = LinearGradient(
        colors: [
            Color(red: 0.2, green: 0.84, blue: 0.29),
            Color(red: 0.0, green: 0.7, blue: 0.6)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// Subtle background ambient gradient.
    static let ambientGradient = RadialGradient(
        colors: [
            Color(red: 1.0, green: 0.369, blue: 0.0).opacity(0.06),
            Color.clear
        ],
        center: .topTrailing,
        startRadius: 50,
        endRadius: 400
    )
    
    // MARK: - Typography
    
    /// Large title (e.g., course name).
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
    
    /// Title.
    static let title = Font.system(size: 22, weight: .bold, design: .default)
    
    /// Section heading.
    static let heading = Font.system(size: 18, weight: .semibold, design: .default)
    
    /// Body text.
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    
    /// Caption / label.
    static let caption = Font.system(size: 13, weight: .medium, design: .default)
    
    /// Small caption.
    static let smallCaption = Font.system(size: 11, weight: .medium, design: .default)
    
    /// Metric value (large, monospaced).
    static let metricLarge = Font.system(size: 32, weight: .bold, design: .monospaced)
    
    /// Metric value (medium, monospaced).
    static let metricMedium = Font.system(size: 22, weight: .bold, design: .monospaced)
    
    /// Metric value (small, monospaced).
    static let metricSmall = Font.system(size: 16, weight: .semibold, design: .monospaced)
    
    // MARK: - Corner Radii
    
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 20
    
    // MARK: - Spacing
    
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 12
    static let spacingL: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32
    
    // MARK: - Shadows
    
    /// Neon glow shadow for accented elements.
    static func neonGlow(radius: CGFloat = 12, opacity: Double = 0.4) -> some View {
        Color.clear
            .shadow(color: neonOrange.opacity(opacity), radius: radius, x: 0, y: 0)
    }
    
    // MARK: - Phase Gradient
    
    /// Get gradient for a specific segment phase.
    static func gradient(for phase: SegmentPhase) -> LinearGradient {
        switch phase {
        case .climb: return climbGradient
        case .descent: return descentGradient
        case .flat: return flatGradient
        }
    }
}

// MARK: - View Modifiers

/// Card style modifier (slate gray container with rounded corners).
struct CardModifier: ViewModifier {
    var padding: CGFloat = Theme.spacingL
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Theme.slateGray)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
    }
}

/// Neon glow border modifier.
struct NeonGlowBorder: ViewModifier {
    var color: Color = Theme.neonOrange
    var radius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.15), radius: radius, x: 0, y: 0)
    }
}

extension View {
    /// Apply card styling.
    func cardStyle(padding: CGFloat = Theme.spacingL) -> some View {
        modifier(CardModifier(padding: padding))
    }
    
    /// Apply neon glow border.
    func neonGlow(color: Color = Theme.neonOrange, radius: CGFloat = 8) -> some View {
        modifier(NeonGlowBorder(color: color, radius: radius))
    }
}
