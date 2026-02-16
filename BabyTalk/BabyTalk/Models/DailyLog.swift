import Foundation

@Observable
class DailyLog: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var entries: [LogEntry]
    var notes: String
    
    init(date: Date, entries: [LogEntry] = [], notes: String = "") {
        self.date = date
        self.entries = entries
        self.notes = notes
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var feedingCount: Int {
        entries.filter { $0.type == .feeding }.count
    }
    
    var diaperCount: Int {
        entries.filter { $0.type == .diaper }.count
    }
    
    var totalSleepMinutes: Int {
        entries.compactMap { entry in
            guard entry.type == .sleep,
                  let sleepDetails = entry.sleepDetails,
                  let totalMinutes = sleepDetails.totalMinutes else { return nil }
            return totalMinutes
        }.reduce(0, +)
    }
    
    var sleepSummary: String {
        let total = totalSleepMinutes
        if total == 0 { return "No sleep recorded" }
        
        let hours = total / 60
        let minutes = total % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m total"
        } else {
            return "\(minutes)m total"
        }
    }
    
    var sortedEntries: [LogEntry] {
        entries.sorted { $0.timestamp < $1.timestamp }
    }
    
    func addEntry(_ entry: LogEntry) {
        entries.append(entry)
    }
    
    func removeEntry(_ entry: LogEntry) {
        entries.removeAll { $0.id == entry.id }
    }
}