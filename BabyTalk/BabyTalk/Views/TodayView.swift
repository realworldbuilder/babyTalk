import SwiftUI

struct TodayView: View {
    @Environment(LogStore.self) private var logStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Baby info header
                    if let baby = logStore.babyProfile {
                        VStack(spacing: 8) {
                            Text(baby.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(baby.ageDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                    }
                    
                    // Summary cards
                    let todayLog = logStore.todayLog
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        SummaryCard(
                            title: "Feedings",
                            count: todayLog.feedingCount,
                            icon: "drop.fill",
                            color: .blue
                        )
                        
                        SummaryCard(
                            title: "Sleep",
                            count: todayLog.totalSleepMinutes,
                            unit: "min",
                            icon: "moon.fill",
                            color: .purple
                        )
                        
                        SummaryCard(
                            title: "Diapers",
                            count: todayLog.diaperCount,
                            icon: "tshirt.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Today's timeline
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Today's Log")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(Date().formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if todayLog.sortedEntries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No entries today")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Tap the Record tab to add your first entry")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 30)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(todayLog.sortedEntries) { entry in
                                    LogEntryRow(entry: entry)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick record button
                    NavigationLink(destination: RecordView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Record New Entry")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Today")
            .refreshable {
                // Refresh data if needed
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let unit: String
    let icon: String
    let color: Color
    
    init(title: String, count: Int, unit: String = "", icon: String, color: Color) {
        self.title = title
        self.count = count
        self.unit = unit
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)\(unit.isEmpty ? "" : " " + unit)")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LogEntryRow: View {
    let entry: LogEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            VStack {
                Text(entry.timeString)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
            
            // Icon
            Image(systemName: entry.type.icon)
                .font(.title3)
                .foregroundColor(colorForType(entry.type))
                .frame(width: 30)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(entry.displaySummary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func colorForType(_ type: LogEntryType) -> Color {
        switch type {
        case .feeding: return .blue
        case .sleep: return .purple
        case .diaper: return .green
        case .note: return .gray
        }
    }
}

#Preview {
    TodayView()
        .environment(LogStore())
}