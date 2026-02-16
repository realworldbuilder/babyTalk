import SwiftUI

struct HistoryView: View {
    @Environment(LogStore.self) private var logStore
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: BabyOpsTheme.spacingL) {
                        datePickerSection
                        quickDateButtons
                        dailySummary
                        timelineSection
                        
                        if Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear) {
                            WeeklySummaryView()
                        }
                    }
                    .padding(.horizontal, BabyOpsTheme.spacingM)
                    .padding(.bottom, BabyOpsTheme.spacingXL)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(themeManager.colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var datePickerSection: some View {
        VStack(spacing: BabyOpsTheme.spacingM) {
            Button(action: { 
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showingDatePicker.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(themeManager.colors.primary)
                        .font(.system(size: 18))
                    
                    Text(selectedDate, style: .date)
                        .font(BabyOpsTheme.fontHeadline)
                        .foregroundColor(themeManager.colors.text)
                    
                    Spacer()
                    
                    Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
                        .foregroundColor(themeManager.colors.primary)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(BabyOpsTheme.spacingM)
                .babyOpsCard()
            }
            .buttonStyle(PlainButtonStyle())
            
            if showingDatePicker {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .babyOpsCard(hasShadow: false)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.top, BabyOpsTheme.spacingM)
    }
    
    private var quickDateButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BabyOpsTheme.spacingS) {
                QuickDateButton(title: "Today", date: Date(), selectedDate: $selectedDate)
                QuickDateButton(title: "Yesterday", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, selectedDate: $selectedDate)
                QuickDateButton(title: "2 days ago", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, selectedDate: $selectedDate)
                QuickDateButton(title: "3 days ago", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, selectedDate: $selectedDate)
            }
            .padding(.horizontal, BabyOpsTheme.spacingM)
        }
    }
    
    private var dailySummary: some View {
        let dailyLog = logStore.dailyLog(for: selectedDate)
        
        return VStack(spacing: BabyOpsTheme.spacingM) {
            HStack {
                Text("Daily Summary")
                    .font(BabyOpsTheme.fontDisplaySmall)
                    .foregroundColor(themeManager.colors.text)
                Spacer()
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BabyOpsTheme.spacingS), count: 3),
                spacing: BabyOpsTheme.spacingS
            ) {
                HistoryStatusCard(
                    title: "Feedings",
                    value: "\(dailyLog.feedingCount)",
                    icon: "drop.fill",
                    color: themeManager.colors.primary
                )
                
                HistoryStatusCard(
                    title: "Sleep",
                    value: formatSleepTime(dailyLog.totalSleepMinutes),
                    icon: "moon.fill",
                    color: themeManager.colors.accent
                )
                
                HistoryStatusCard(
                    title: "Diapers",
                    value: "\(dailyLog.diaperCount)",
                    icon: "figure.2.and.child.holdinghands",
                    color: themeManager.colors.primary.opacity(0.8)
                )
            }
        }
    }
    
    private var timelineSection: some View {
        let dailyLog = logStore.dailyLog(for: selectedDate)
        
        return VStack(alignment: .leading, spacing: BabyOpsTheme.spacingM) {
            HStack {
                Text("Operations Timeline")
                    .font(BabyOpsTheme.fontDisplaySmall)
                    .foregroundColor(themeManager.colors.text)
                Spacer()
            }
            
            if dailyLog.sortedEntries.isEmpty {
                emptyTimelineView
            } else {
                LazyVStack(spacing: BabyOpsTheme.spacingS) {
                    ForEach(dailyLog.sortedEntries) { entry in
                        HistoryTimelineEntryCard(entry: entry)
                    }
                }
            }
        }
    }
    
    private var emptyTimelineView: some View {
        VStack(spacing: BabyOpsTheme.spacingM) {
            Image(systemName: "timeline.selection")
                .font(.system(size: 50))
                .foregroundColor(themeManager.colors.text.opacity(0.3))
            
            VStack(spacing: BabyOpsTheme.spacingS) {
                Text(Calendar.current.isDateInToday(selectedDate) ? "No Ops Today" : "No Ops This Day")
                    .font(BabyOpsTheme.fontHeadline)
                    .foregroundColor(themeManager.colors.text.opacity(0.6))
                
                if Calendar.current.isDateInToday(selectedDate) {
                    Text("Start tracking your baby's activities")
                        .font(BabyOpsTheme.fontBody)
                        .foregroundColor(themeManager.colors.text.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.vertical, BabyOpsTheme.spacingXL)
        .babyOpsCard(hasShadow: false)
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
}

struct QuickDateButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    let date: Date
    @Binding var selectedDate: Date
    
    var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        Button(action: { 
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                selectedDate = date
            }
        }) {
            Text(title)
                .font(BabyOpsTheme.fontCaption)
                .fontWeight(.medium)
                .statusPill(isActive: isSelected)
        }
    }
}

struct HistoryStatusCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: BabyOpsTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: BabyOpsTheme.spacingXS) {
                Text(value)
                    .font(BabyOpsTheme.fontHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.colors.text)
                
                Text(title)
                    .font(BabyOpsTheme.fontCaption)
                    .foregroundColor(themeManager.colors.text.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(BabyOpsTheme.spacingM)
        .babyOpsCard()
    }
}

struct HistoryTimelineEntryCard: View {
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

struct WeeklySummaryView: View {
    @Environment(LogStore.self) private var logStore
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: BabyOpsTheme.spacingM) {
            HStack {
                Text("Week Summary")
                    .font(BabyOpsTheme.fontDisplaySmall)
                    .foregroundColor(themeManager.colors.text)
                Spacer()
            }
            
            let weekData = calculateWeekData()
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: BabyOpsTheme.spacingS), count: 3),
                spacing: BabyOpsTheme.spacingS
            ) {
                WeekStatCard(
                    title: "Avg Feeds",
                    value: String(format: "%.1f", weekData.avgFeedings),
                    icon: "drop.fill",
                    color: themeManager.colors.primary
                )
                
                WeekStatCard(
                    title: "Avg Sleep",
                    value: formatMinutes(Int(weekData.avgSleep)),
                    icon: "moon.fill",
                    color: themeManager.colors.accent
                )
                
                WeekStatCard(
                    title: "Avg Diapers",
                    value: String(format: "%.1f", weekData.avgDiapers),
                    icon: "figure.2.and.child.holdinghands",
                    color: themeManager.colors.primary.opacity(0.8)
                )
            }
        }
    }
    
    private func calculateWeekData() -> (avgFeedings: Double, avgSleep: Double, avgDiapers: Double) {
        let calendar = Calendar.current
        let today = Date()
        var totalFeedings = 0
        var totalSleep = 0
        var totalDiapers = 0
        var daysWithData = 0
        
        // Look at last 7 days
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dailyLog = logStore.dailyLog(for: date)
            
            if !dailyLog.sortedEntries.isEmpty {
                daysWithData += 1
                totalFeedings += dailyLog.feedingCount
                totalSleep += dailyLog.totalSleepMinutes
                totalDiapers += dailyLog.diaperCount
            }
        }
        
        let divisor = max(daysWithData, 1)
        return (
            avgFeedings: Double(totalFeedings) / Double(divisor),
            avgSleep: Double(totalSleep) / Double(divisor),
            avgDiapers: Double(totalDiapers) / Double(divisor)
        )
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
}

struct WeekStatCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: BabyOpsTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            VStack(spacing: BabyOpsTheme.spacingXS) {
                Text(value)
                    .font(BabyOpsTheme.fontHeadline)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.colors.text)
                
                Text(title)
                    .font(BabyOpsTheme.fontCaption)
                    .foregroundColor(themeManager.colors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(BabyOpsTheme.spacingM)
        .babyOpsCard()
    }
}

#Preview {
    HistoryView()
        .environment(LogStore())
        .environment(ThemeManager.shared)
}