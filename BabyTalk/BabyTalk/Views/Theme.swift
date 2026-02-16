// This file is deprecated and replaced by ThemeManager.swift
// Keeping for compatibility during transition
import SwiftUI

// Legacy theme - will be removed once all views are migrated to BabyOps theme
enum Theme {
    // MARK: - Backgrounds (deprecated - use ThemeManager)
    static let background = Color.black
    static let cardBackground = Color(white: 0.11)

    // MARK: - Accent (deprecated - use ThemeManager)
    static let accent = Color.green
    static let accentSubtle = Color.green.opacity(0.15)

    // MARK: - Text (deprecated - use ThemeManager)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textTertiary = Color.white.opacity(0.35)

    // MARK: - Divider (deprecated - use ThemeManager)
    static let divider = Color.white.opacity(0.06)

    // MARK: - Corner Radii (deprecated - use BabyOpsTheme)
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
}

// MARK: - Legacy Theme Card Modifier (deprecated - use babyOpsCard)

struct ThemeCardModifier: ViewModifier {
    var cornerRadius: CGFloat = Theme.radiusMedium

    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func themeCard(cornerRadius: CGFloat = Theme.radiusMedium) -> some View {
        modifier(ThemeCardModifier(cornerRadius: cornerRadius))
    }
}