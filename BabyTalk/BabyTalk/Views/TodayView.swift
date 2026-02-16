import SwiftUI

struct TodayView: View {
    @Environment(LogStore.self) private var logStore
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: BabyOpsTheme.spacingL) {
                        dashboardHeader
                        statusCards
                        timelineSection
                        quickActionButton
                    }
                    .padding(.horizontal, BabyOpsTheme.spacingM)
                    .padding(.bottom, BabyOpsTheme.spacingXL)
                }
            }
            .navigationTitle("Mission Control")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(themeManager.colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .refreshable {
                // Refresh data if needed
            }
        }
    }
    
    private var dashboardHeader: some View {
        VStack(spacing: BabyOpsTheme.spacingS) {
            if let baby = logStore.babyProfile {
                HStack {
                    VStack(alignment: .leading, spacing: BabyOpsTheme.spacingXS) {
                        Text(baby.name)
                            .font(BabyOpsTheme.fontDisplaySmall)
                            .foregroundColor(themeManager.colors.text)
                        
                        Text(baby.ageDescription)
                            .font(BabyOpsTheme.fontBody)
                            .foregroundColor(themeManager.colors.text.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: BabyOpsTheme.spacingXS) {
                        Text("Today")
                            .font(BabyOpsTheme.fontCaption)
                            .foregroundColor(themeManager.colors.text.opacity(0.6))
                        
                        Text(Date().formatted(date: .abbreviated, time: .omitted))
                            .font(BabyOpsTheme.fontBody)
                            .fontWeight(.medium)
                            .foregroundColor(themeManager.colors.primary)
                    }
                }
            }
        }
        .padding(.top, BabyOpsTheme.spacingM)
    }
    
    private var statusCards: some View {
        let todayLog = logStore.todayLog
        
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: BabyOpsTheme.spacingS), count: 3),
            spacing: BabyOpsTheme.spacingS
        ) {
            StatusCard(
                title: "Feedings",
                value: "\(todayLog.feedingCount)",
                icon: "drop.fill",
                color: themeManager.colors.primary,
                lastEvent: lastFeedingTime()
            )
            
            StatusCard(
                title: "Sleep",
                value: formatSleepTime(todayLog.totalSleepMinutes),
                icon: "moon.fill",
                color: themeManager.colors.accent,
                lastEvent: lastSleepTime()
            )
            
            StatusCard(
                title: "Diapers",
                value: "\(todayLog.diaperCount)",
                icon: "figure.2.and.child.holdinghands",
                color: themeManager.colors.primary.opacity(0.8),
                lastEvent: lastDiaperTime()
            )
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: BabyOpsTheme.spacingM) {
            HStack {
                Text("Today's Timeline")
                    .font(BabyOpsTheme.fontDisplaySmall)
                    .foregroundColor(themeManager.colors.text)
                
                Spacer()
                
                Button(action: {
                    // TODO: Show filter options
                }) {
                    HStack(spacing: BabyOpsTheme.spacingXS) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filter")
                    }
                    .font(BabyOpsTheme.fontCaption)
                    .foregroundColor(themeManager.colors.primary)
                }
                .statusPill()
            }
            
            timelineContent
        }
    }
    
    private var timelineContent: some View {
        let todayLog = logStore.todayLog
        
        return Group {
            if todayLog.sortedEntries.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: BabyOpsTheme.spacingS) {
                    ForEach(todayLog.sortedEntries) { entry in
                        TimelineEntryCard(entry: entry)
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: BabyOpsTheme.spacingM) {
            Image(systemName: "timeline.selection")
                .font(.system(size: 50))
                .foregroundColor(themeManager.colors.text.opacity(0.3))
            
            VStack(spacing: BabyOpsTheme.spacingS) {
                Text("No Ops Today")
                    .font(BabyOpsTheme.fontHeadline)
                    .foregroundColor(themeManager.colors.text.opacity(0.6))
                
                Text("Start tracking your baby's activities")
                    .font(BabyOpsTheme.fontBody)
                    .foregroundColor(themeManager.colors.text.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, BabyOpsTheme.spacingXL)
        .babyOpsCard(hasShadow: false)
    }
    
    private var quickActionButton: some View {
        NavigationLink(destination: RecordView()) {
            HStack(spacing: BabyOpsTheme.spacingS) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                
                Text("New Operation")
                    .font(BabyOpsTheme.fontHeadline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(BabyOpsTheme.spacingM)
            .background(
                LinearGradient(
                    colors: [themeManager.colors.primary, themeManager.colors.accent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: BabyOpsTheme.radiusM))
            .shadow(
                color: themeManager.colors.primary.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatSleepTime(_ minutes: Int) -> String {
        if minutes == 0 { return "0m" }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
    
    private func lastFeedingTime() -> String? {
        return lastEventTime(for: .feeding)
    }
    
    private func lastSleepTime() -> String? {
        return lastEventTime(for: .sleep)
    }
    
    private func lastDiaperTime() -> String? {
        return lastEventTime(for: .diaper)
    }
    
    private func lastEventTime(for type: LogEntryType) -> String? {
        let todayLog = logStore.todayLog
        let entries = todayLog.sortedEntries.filter { $0.type == type }
        guard let lastEntry = entries.first else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: lastEntry.timestamp)
    }
}

struct StatusCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    let value: String
    let icon: String
    let color: Color
    let lastEvent: String?
    
    var body: some View {
        VStack(spacing: BabyOpsTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: BabyOpsTheme.spacingXS) {
                Text(value)
                    .font(BabyOpsTheme.fontDisplaySmall)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.colors.text)
                
                Text(title)
                    .font(BabyOpsTheme.fontCaption)
                    .foregroundColor(themeManager.colors.text.opacity(0.7))
                
                if let lastEvent = lastEvent {
                    Text("Last: \(lastEvent)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(color.opacity(0.8))
                        .statusPill()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(BabyOpsTheme.spacingM)
        .babyOpsCard()
    }
}

struct TimelineEntryCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let entry: LogEntry
    
    var body: some View {
        HStack(spacing: BabyOpsTheme.spacingM) {
            // Timeline indicator
            VStack {
                Circle()
                    .fill(colorForType(entry.type))
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(themeManager.colors.subtle)
                    .frame(width: 2, height: 30)
            }
            
            // Content
            VStack(alignment: .leading, spacing: BabyOpsTheme.spacingXS) {
                HStack {
                    HStack(spacing: BabyOpsTheme.spacingXS) {
                        Image(systemName: entry.type.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(colorForType(entry.type))
                        
                        Text(entry.type.displayName)
                            .font(BabyOpsTheme.fontHeadline)
                            .foregroundColor(themeManager.colors.text)
                    }
                    
                    Spacer()
                    
                    Text(entry.timeString)
                        .font(BabyOpsTheme.fontCaption)
                        .foregroundColor(themeManager.colors.text.opacity(0.6))
                        .statusPill()
                }
                
                if !entry.displaySummary.isEmpty {
                    Text(entry.displaySummary)
                        .font(BabyOpsTheme.fontBody)
                        .foregroundColor(themeManager.colors.text.opacity(0.8))
                }
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(BabyOpsTheme.fontBody)
                        .foregroundColor(themeManager.colors.text.opacity(0.6))
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding(BabyOpsTheme.spacingM)
        .babyOpsCard()
    }
    
    private func colorForType(_ type: LogEntryType) -> Color {
        switch type {
        case .feeding: return themeManager.colors.primary
        case .sleep: return themeManager.colors.accent
        case .diaper: return themeManager.colors.primary.opacity(0.8)
        case .note: return themeManager.colors.text.opacity(0.6)
        }
    }
}

#Preview {
    TodayView()
        .environment(LogStore())
        .environment(ThemeManager.shared)
}