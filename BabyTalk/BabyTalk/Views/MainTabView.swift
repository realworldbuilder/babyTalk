import SwiftUI

struct MainTabView: View {
    @Environment(LogStore.self) private var logStore
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedTab = 0
    @State private var showThemePicker = false
    
    var body: some View {
        Group {
            if logStore.babyProfile == nil || !themeManager.hasSelectedTheme {
                SetupView()
                    .transition(.opacity)
            } else {
                TabView(selection: $selectedTab) {
                    TodayView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Today")
                        }
                        .tag(0)
                    
                    RecordView()
                        .tabItem {
                            Image(systemName: "mic.fill")
                            Text("Record")
                        }
                        .tag(1)
                    
                    HistoryView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("History")
                        }
                        .tag(2)
                    
                    ChatView()
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(4)
                }
                .accentColor(themeManager.colors.primary)
                .background(themeManager.colors.background)
            }
        }
        .background(themeManager.colors.background)
    }
}

struct SetupView: View {
    @Environment(LogStore.self) private var logStore
    @Environment(ThemeManager.self) private var themeManager
    @State private var setupStep = 0 // 0: theme, 1: profile
    @State private var babyName = ""
    @State private var birthDate = Date()
    @State private var isShowingDatePicker = false
    
    var body: some View {
        ZStack {
            themeManager.colors.background
                .ignoresSafeArea()
            
            if setupStep == 0 {
                ThemePickerView {
                    withAnimation(.easeInOut) {
                        setupStep = 1
                    }
                }
            } else {
                profileSetupView
            }
        }
    }
    
    private var profileSetupView: some View {
        NavigationView {
            VStack(spacing: BabyOpsTheme.spacingXL) {
                headerSection
                profileForm
                Spacer()
                continueButton
            }
            .padding(BabyOpsTheme.spacingL)
            .background(themeManager.colors.background)
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: BabyOpsTheme.spacingM) {
            Image(systemName: "figure.2.and.child.holdinghands")
                .font(.system(size: 80))
                .foregroundColor(themeManager.colors.primary)
            
            Text("Welcome to BabyOps")
                .font(BabyOpsTheme.fontDisplayLarge)
                .foregroundColor(themeManager.colors.text)
                .multilineTextAlignment(.center)
            
            Text("Mission Control for Your Baby")
                .font(BabyOpsTheme.fontBody)
                .foregroundColor(themeManager.colors.text.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, BabyOpsTheme.spacingXL)
    }
    
    private var profileForm: some View {
        VStack(spacing: BabyOpsTheme.spacingL) {
            VStack(alignment: .leading, spacing: BabyOpsTheme.spacingS) {
                Text("Baby's Name")
                    .font(BabyOpsTheme.fontHeadline)
                    .foregroundColor(themeManager.colors.text)
                
                TextField("Enter your baby's name", text: $babyName)
                    .padding(BabyOpsTheme.spacingM)
                    .background(themeManager.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM))
                    .shadow(
                        color: BabyOpsTheme.shadowSubtle.color,
                        radius: BabyOpsTheme.shadowSubtle.radius,
                        x: BabyOpsTheme.shadowSubtle.x,
                        y: BabyOpsTheme.shadowSubtle.y
                    )
                    .font(BabyOpsTheme.fontBody)
                    .foregroundColor(themeManager.colors.text)
            }
            
            VStack(alignment: .leading, spacing: BabyOpsTheme.spacingS) {
                Text("Birth Date")
                    .font(BabyOpsTheme.fontHeadline)
                    .foregroundColor(themeManager.colors.text)
                
                Button(action: { 
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isShowingDatePicker.toggle()
                    }
                }) {
                    HStack {
                        Text(birthDate, style: .date)
                            .foregroundColor(themeManager.colors.text)
                            .font(BabyOpsTheme.fontBody)
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(themeManager.colors.primary)
                            .font(.system(size: 18))
                    }
                    .padding(BabyOpsTheme.spacingM)
                    .background(themeManager.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM))
                    .shadow(
                        color: BabyOpsTheme.shadowSubtle.color,
                        radius: BabyOpsTheme.shadowSubtle.radius,
                        x: BabyOpsTheme.shadowSubtle.x,
                        y: BabyOpsTheme.shadowSubtle.y
                    )
                }
                
                if isShowingDatePicker {
                    DatePicker("Birth Date", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .background(themeManager.colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM))
                        .padding(.top, BabyOpsTheme.spacingS)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: createProfile) {
            HStack(spacing: BabyOpsTheme.spacingS) {
                Text("Launch BabyOps")
                    .font(BabyOpsTheme.fontHeadline)
                
                Image(systemName: "rocket.fill")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(BabyOpsTheme.spacingM)
            .background(
                RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM)
                    .fill(
                        babyName.isEmpty 
                        ? themeManager.colors.text.opacity(0.3)
                        : themeManager.colors.primary
                    )
            )
            .scaleEffect(babyName.isEmpty ? 0.98 : 1.0)
            .shadow(
                color: babyName.isEmpty ? .clear : themeManager.colors.primary.opacity(0.3),
                radius: babyName.isEmpty ? 0 : 8,
                x: 0,
                y: babyName.isEmpty ? 0 : 4
            )
        }
        .disabled(babyName.isEmpty)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: babyName.isEmpty)
        .padding(.bottom, BabyOpsTheme.spacingL)
    }
    
    private func createProfile() {
        guard !babyName.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            logStore.createBabyProfile(name: babyName, birthDate: birthDate)
        }
    }
}

#Preview {
    MainTabView()
        .environment(LogStore())
}