import SwiftUI

struct ThemePickerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedTheme: BabyThemeType = .boy
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: BabyOpsTheme.spacingXL) {
            headerSection
            themeOptions
            continueButton
        }
        .padding(BabyOpsTheme.spacingL)
        .background(themeManager.colors.background)
        .onAppear {
            selectedTheme = themeManager.selectedTheme
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: BabyOpsTheme.spacingM) {
            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.colors.primary)
                .padding(.top, BabyOpsTheme.spacingXL)
            
            Text("Choose Your Theme")
                .font(BabyOpsTheme.fontDisplayMedium)
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
            
            Text("Pick a color scheme that feels right for your baby. You can change this later in Settings.")
                .font(BabyOpsTheme.fontBody)
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, BabyOpsTheme.spacingM)
        }
    }
    
    private var themeOptions: some View {
        VStack(spacing: BabyOpsTheme.spacingM) {
            ForEach(BabyThemeType.allCases, id: \.self) { theme in
                ThemeOptionCard(
                    theme: theme,
                    isSelected: selectedTheme == theme,
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTheme = theme
                            themeManager.selectTheme(theme)
                        }
                    }
                )
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                onComplete()
            }
        }) {
            HStack(spacing: BabyOpsTheme.spacingS) {
                Text("Continue")
                    .font(BabyOpsTheme.fontHeadline)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(BabyOpsTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM)
                    .fill(themeManager.colors.primary)
            )
        }
        .padding(.top, BabyOpsTheme.spacingL)
    }
}

struct ThemeOptionCard: View {
    let theme: BabyThemeType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BabyOpsTheme.spacingM) {
                // Theme preview circle
                ZStack {
                    Circle()
                        .fill(theme.colors.primary)
                        .frame(width: 50, height: 50)
                    
                    if isSelected {
                        Circle()
                            .stroke(.white, lineWidth: 3)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: BabyOpsTheme.spacingXS) {
                    Text(theme.displayName)
                        .font(BabyOpsTheme.fontHeadline)
                        .foregroundColor(theme.colors.text)
                    
                    Text(themeDescription(for: theme))
                        .font(BabyOpsTheme.fontCaption)
                        .foregroundColor(theme.colors.text.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Color palette preview
                HStack(spacing: 4) {
                    ForEach([theme.colors.primary, theme.colors.accent, theme.colors.subtle], id: \.description) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(BabyOpsTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM)
                    .fill(theme.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM)
                            .stroke(
                                isSelected ? theme.colors.primary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? theme.colors.primary.opacity(0.2) : .clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func themeDescription(for theme: BabyThemeType) -> String {
        switch theme {
        case .boy:
            return "Cool blues for a calming, confident feel"
        case .girl:
            return "Warm roses for a gentle, loving atmosphere"
        }
    }
}

#Preview {
    ThemePickerView {
        // onComplete
    }
    .environment(ThemeManager.shared)
}