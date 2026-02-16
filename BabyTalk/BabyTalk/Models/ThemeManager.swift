import SwiftUI
import Foundation

// MARK: - Theme Types

enum BabyThemeType: String, CaseIterable, Codable {
    case boy = "boy"
    case girl = "girl"
    case neutral = "neutral"
    
    var displayName: String {
        switch self {
        case .boy: return "Boy"
        case .girl: return "Girl" 
        case .neutral: return "Neutral"
        }
    }
    
    var colors: ThemeColors {
        switch self {
        case .boy:
            return ThemeColors(
                primary: Color(hex: "4A90D9"),
                background: Color(hex: "F8FAFD"),
                surface: Color(hex: "FFFFFF"),
                accent: Color(hex: "6B9BD2"),
                text: Color(hex: "1A2B3C"),
                subtle: Color(hex: "E8F0FE")
            )
        case .girl:
            return ThemeColors(
                primary: Color(hex: "D4849A"),
                background: Color(hex: "FDF6F8"),
                surface: Color(hex: "FFFFFF"),
                accent: Color(hex: "E8A0B5"),
                text: Color(hex: "2C1A21"),
                subtle: Color(hex: "FDE8EF")
            )
        case .neutral:
            return ThemeColors(
                primary: Color(hex: "7BA37E"),
                background: Color(hex: "F7F5F0"),
                surface: Color(hex: "FFFFFF"),
                accent: Color(hex: "8BA888"),
                text: Color(hex: "2A2A25"),
                subtle: Color(hex: "EEF0E8")
            )
        }
    }
    
    var icon: String {
        switch self {
        case .boy: return "figure.child"
        case .girl: return "figure.dress.line.vertical.figure"
        case .neutral: return "heart.fill"
        }
    }
}

// MARK: - Theme Colors

struct ThemeColors {
    let primary: Color
    let background: Color
    let surface: Color
    let accent: Color
    let text: Color
    let subtle: Color
}

// MARK: - Theme Manager

@Observable
class ThemeManager {
    static let shared = ThemeManager()
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selectedTheme"
    
    var selectedTheme: BabyThemeType {
        didSet {
            userDefaults.set(selectedTheme.rawValue, forKey: themeKey)
        }
    }
    
    var hasSelectedTheme: Bool {
        return userDefaults.object(forKey: themeKey) != nil
    }
    
    var colors: ThemeColors {
        return selectedTheme.colors
    }
    
    private init() {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = BabyThemeType(rawValue: themeString) {
            selectedTheme = theme
        } else {
            selectedTheme = .neutral // Default
        }
    }
    
    func selectTheme(_ theme: BabyThemeType) {
        selectedTheme = theme
    }
}

// MARK: - Modern Theme Constants

struct BabyOpsTheme {
    // Typography
    static let fontDisplayLarge = Font.system(.largeTitle, design: .default, weight: .bold)
    static let fontDisplayMedium = Font.system(.title, design: .default, weight: .bold)
    static let fontDisplaySmall = Font.system(.title2, design: .default, weight: .semibold)
    static let fontHeadline = Font.system(.headline, design: .default, weight: .semibold)
    static let fontBody = Font.system(.body, design: .default, weight: .regular)
    static let fontCaption = Font.system(.caption, design: .default, weight: .medium)
    
    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // Corner Radii
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 24
    
    // Shadows
    static let shadowCard = Shadow(
        color: .black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )
    
    static let shadowSubtle = Shadow(
        color: .black.opacity(0.04),
        radius: 4,
        x: 0,
        y: 1
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex Support

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

// MARK: - View Modifiers

struct BabyOpsCardModifier: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager
    let cornerRadius: CGFloat
    let hasShadow: Bool
    
    func body(content: Content) -> some View {
        content
            .background(themeManager.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: hasShadow ? BabyOpsTheme.shadowCard.color : .clear,
                radius: hasShadow ? BabyOpsTheme.shadowCard.radius : 0,
                x: hasShadow ? BabyOpsTheme.shadowCard.x : 0,
                y: hasShadow ? BabyOpsTheme.shadowCard.y : 0
            )
    }
}

struct StatusPillModifier: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, BabyOpsTheme.spacingM)
            .padding(.vertical, BabyOpsTheme.spacingS)
            .background(
                isActive ? themeManager.colors.primary : themeManager.colors.subtle
            )
            .foregroundColor(
                isActive ? .white : themeManager.colors.text
            )
            .clipShape(Capsule())
            .font(BabyOpsTheme.fontCaption)
            .fontWeight(.medium)
    }
}

// MARK: - View Extensions

extension View {
    func babyOpsCard(cornerRadius: CGFloat = BabyOpsTheme.radiusM, hasShadow: Bool = true) -> some View {
        modifier(BabyOpsCardModifier(cornerRadius: cornerRadius, hasShadow: hasShadow))
    }
    
    func statusPill(isActive: Bool = false) -> some View {
        modifier(StatusPillModifier(isActive: isActive))
    }
}