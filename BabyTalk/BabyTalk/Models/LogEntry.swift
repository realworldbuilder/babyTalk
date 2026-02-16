import Foundation

// MARK: - LogEntry Types

enum LogEntryType: String, CaseIterable, Codable {
    case feeding = "feeding"
    case sleep = "sleep"
    case diaper = "diaper"
    case note = "note"
    
    var displayName: String {
        switch self {
        case .feeding: return "Feeding"
        case .sleep: return "Sleep"
        case .diaper: return "Diaper"
        case .note: return "Note"
        }
    }
    
    var icon: String {
        switch self {
        case .feeding: return "drop.fill"
        case .sleep: return "moon.fill"
        case .diaper: return "tshirt.fill"
        case .note: return "note.text"
        }
    }
    
    var color: String {
        switch self {
        case .feeding: return "blue"
        case .sleep: return "purple"
        case .diaper: return "green"
        case .note: return "gray"
        }
    }
}

// MARK: - Detail Types

enum FeedingMethod: String, Codable, CaseIterable {
    case nurseLeft = "nurse_left"
    case nurseRight = "nurse_right"  
    case bottle = "bottle"
    
    var displayName: String {
        switch self {
        case .nurseLeft: return "Nurse Left"
        case .nurseRight: return "Nurse Right"
        case .bottle: return "Bottle"
        }
    }
}

struct FeedingDetails: Codable {
    var method: FeedingMethod
    var amount: Double? // oz or ml
    var duration: Int? // minutes
    var unit: String? // "oz" or "ml"
    
    init(method: FeedingMethod, amount: Double? = nil, duration: Int? = nil, unit: String? = nil) {
        self.method = method
        self.amount = amount
        self.duration = duration
        self.unit = unit
    }
}

struct SleepDetails: Codable {
    var startTime: Date
    var endTime: Date?
    var totalMinutes: Int?
    
    init(startTime: Date, endTime: Date? = nil, totalMinutes: Int? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.totalMinutes = totalMinutes
    }
}

struct DiaperDetails: Codable {
    var wet: Bool
    var dirty: Bool
    
    init(wet: Bool, dirty: Bool) {
        self.wet = wet
        self.dirty = dirty
    }
}

// MARK: - LogEntry

@Observable
class LogEntry: Codable, Identifiable {
    var id = UUID()
    var babyId: UUID
    var timestamp: Date
    var type: LogEntryType
    var feedingDetails: FeedingDetails?
    var sleepDetails: SleepDetails?
    var diaperDetails: DiaperDetails?
    var notes: String
    var createdAt: Date
    
    init(babyId: UUID, timestamp: Date, type: LogEntryType, notes: String = "") {
        self.babyId = babyId
        self.timestamp = timestamp
        self.type = type
        self.notes = notes
        self.createdAt = Date()
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var displaySummary: String {
        switch type {
        case .feeding:
            if let feeding = feedingDetails {
                var summary = feeding.method.displayName
                if let duration = feeding.duration {
                    summary += " • \(duration) min"
                }
                if let amount = feeding.amount, let unit = feeding.unit {
                    summary += " • \(amount.formatted())\(unit)"
                }
                return summary
            }
            return "Feeding"
            
        case .sleep:
            if let sleep = sleepDetails {
                if let totalMinutes = sleep.totalMinutes {
                    let hours = totalMinutes / 60
                    let mins = totalMinutes % 60
                    if hours > 0 {
                        return "Slept \(hours)h \(mins)m"
                    } else {
                        return "Slept \(mins)m"
                    }
                }
                return "Sleep started"
            }
            return "Sleep"
            
        case .diaper:
            if let diaper = diaperDetails {
                var parts: [String] = []
                if diaper.wet { parts.append("Wet") }
                if diaper.dirty { parts.append("Dirty") }
                return parts.isEmpty ? "Diaper change" : parts.joined(separator: " & ")
            }
            return "Diaper change"
            
        case .note:
            return notes.isEmpty ? "Note" : String(notes.prefix(50))
        }
    }
}