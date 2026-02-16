import Foundation

@Observable
class LogStore {
    private let fileManager = FileManager.default
    private let documentsURL: URL
    
    var babyProfile: BabyProfile?
    var dailyLogs: [String: DailyLog] = [:]
    
    init() {
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadData()
    }
    
    // MARK: - File paths
    
    private var babyProfileURL: URL {
        documentsURL.appendingPathComponent("baby_profile.json")
    }
    
    private func dailyLogURL(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return documentsURL.appendingPathComponent("daily_log_\(dateString).json")
    }
    
    // MARK: - Load/Save
    
    private func loadData() {
        loadBabyProfile()
        loadRecentDailyLogs()
    }
    
    private func loadBabyProfile() {
        guard fileManager.fileExists(atPath: babyProfileURL.path),
              let data = try? Data(contentsOf: babyProfileURL),
              let profile = try? JSONDecoder().decode(BabyProfile.self, from: data) else {
            return
        }
        babyProfile = profile
    }
    
    private func loadRecentDailyLogs() {
        // Load last 30 days
        let calendar = Calendar.current
        let endDate = Date()
        
        for i in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: endDate) else { continue }
            loadDailyLog(for: date)
        }
    }
    
    private func loadDailyLog(for date: Date) {
        let url = dailyLogURL(for: date)
        let dateKey = dayKey(for: date)
        
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let dailyLog = try? JSONDecoder().decode(DailyLog.self, from: data) else {
            // Create empty daily log if file doesn't exist
            dailyLogs[dateKey] = DailyLog(date: date)
            return
        }
        
        dailyLogs[dateKey] = dailyLog
    }
    
    func saveBabyProfile() {
        guard let profile = babyProfile else { return }
        
        do {
            let data = try JSONEncoder().encode(profile)
            try data.write(to: babyProfileURL)
        } catch {
            print("Error saving baby profile: \(error)")
        }
    }
    
    func saveDailyLog(for date: Date) {
        let dateKey = dayKey(for: date)
        guard let dailyLog = dailyLogs[dateKey] else { return }
        
        let url = dailyLogURL(for: date)
        
        do {
            let data = try JSONEncoder().encode(dailyLog)
            try data.write(to: url)
        } catch {
            print("Error saving daily log: \(error)")
        }
    }
    
    // MARK: - Helper methods
    
    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func dailyLog(for date: Date) -> DailyLog {
        let dateKey = dayKey(for: date)
        
        if let existing = dailyLogs[dateKey] {
            return existing
        }
        
        // Create new daily log if it doesn't exist
        let newLog = DailyLog(date: date)
        dailyLogs[dateKey] = newLog
        loadDailyLog(for: date) // This will load from file if it exists
        
        return dailyLogs[dateKey]!
    }
    
    func addLogEntry(_ entry: LogEntry) {
        let calendar = Calendar.current
        let entryDate = calendar.startOfDay(for: entry.timestamp)
        let dailyLog = dailyLog(for: entryDate)
        
        dailyLog.addEntry(entry)
        saveDailyLog(for: entryDate)
    }
    
    func removeLogEntry(_ entry: LogEntry) {
        let calendar = Calendar.current
        let entryDate = calendar.startOfDay(for: entry.timestamp)
        let dailyLog = dailyLog(for: entryDate)
        
        dailyLog.removeEntry(entry)
        saveDailyLog(for: entryDate)
    }
    
    func createBabyProfile(name: String, birthDate: Date) {
        babyProfile = BabyProfile(name: name, birthDate: birthDate)
        saveBabyProfile()
    }
    
    var todayLog: DailyLog {
        dailyLog(for: Date())
    }
}