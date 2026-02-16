import SwiftUI

struct HistoryView: View {
    @Environment(LogStore.self) private var logStore
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date picker section
                    VStack(spacing: 16) {
                        Button(action: { showingDatePicker.toggle() }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(selectedDate, style: .date)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
                            }
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        if showingDatePicker {
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Quick date buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            QuickDateButton(title: "Today", date: Date(), selectedDate: $selectedDate)
                            QuickDateButton(title: "Yesterday", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, selectedDate: $selectedDate)
                            QuickDateButton(title: "2 days ago", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, selectedDate: $selectedDate)
                            QuickDateButton(title: "3 days ago", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, selectedDate: $selectedDate)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Daily summary
                    let dailyLog = logStore.dailyLog(for: selectedDate)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Summary")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            SummaryCard(
                                title: "Feedings",
                                count: dailyLog.feedingCount,
                                icon: "drop.fill",
                                color: .blue
                            )
                            
                            SummaryCard(
                                title: "Sleep",
                                count: dailyLog.totalSleepMinutes,
                                unit: "min",
                                icon: "moon.fill",
                                color: .purple
                            )
                            
                            SummaryCard(
                                title: "Diapers",
                                count: dailyLog.diaperCount,
                                icon: "tshirt.fill",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Timeline
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Timeline")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if dailyLog.sortedEntries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No entries for this day")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                if Calendar.current.isDateInToday(selectedDate) {
                                    Text("Tap the Record tab to add an entry")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 30)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(dailyLog.sortedEntries) { entry in
                                    LogEntryRow(entry: entry)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Weekly summary (if looking at this week)
                    if Calendar.current.isDate(selectedDate, equalTo: Date(), toGranularity: .weekOfYear) {
                        WeeklySummaryView()
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("History")
        }
    }
}

struct QuickDateButton: View {
    let title: String
    let date: Date
    @Binding var selectedDate: Date
    
    var isSelected: Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        Button(action: { selectedDate = date }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct WeeklySummaryView: View {
    @Environment(LogStore.self) private var logStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week Summary")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            
            let weekData = calculateWeekData()
            
            HStack(spacing: 16) {
                WeekStatCard(
                    title: "Avg Feedings/Day",
                    value: String(format: "%.1f", weekData.avgFeedings),
                    icon: "drop.fill",
                    color: .blue
                )
                
                WeekStatCard(
                    title: "Avg Sleep/Day",
                    value: formatMinutes(Int(weekData.avgSleep)),
                    icon: "moon.fill",
                    color: .purple
                )
                
                WeekStatCard(
                    title: "Avg Diapers/Day",
                    value: String(format: "%.1f", weekData.avgDiapers),
                    icon: "tshirt.fill",
                    color: .green
                )
            }
            .padding(.horizontal)
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
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

struct WeekStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HistoryView()
        .environment(LogStore())
}