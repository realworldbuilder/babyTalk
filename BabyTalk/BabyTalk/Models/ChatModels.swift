import Foundation

// Chat Block Types
struct ChatBlock: Identifiable, Hashable {
    let id: UUID
    let type: ChatBlockType
    let payload: ChatBlockPayload
    let timestamp: Date
    
    init(type: ChatBlockType, payload: ChatBlockPayload) {
        self.id = UUID()
        self.type = type
        self.payload = payload
        self.timestamp = Date()
    }
}

enum ChatBlockType {
    case text
    case metrics
    case insights
    case timeline
    case recommendations
    case question
    case chart
}

enum ChatBlockPayload: Hashable {
    case text(String)
    case metrics([ChatMetric])
    case insights([String])
    case timeline([TimelineEvent])
    case recommendations([String])
    case question(String, options: [String])
    case chart(ChatChart)
}

struct ChatMetric: Identifiable, Hashable {
    let id: UUID
    let name: String
    let value: String
    let unit: String?
    let trend: ChatMetricTrend?
    
    init(name: String, value: String, unit: String? = nil, trend: ChatMetricTrend? = nil) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.unit = unit
        self.trend = trend
    }
}

enum ChatMetricTrend {
    case up
    case down
    case stable
}

struct TimelineEvent: Identifiable, Hashable {
    let id: UUID
    let time: Date
    let title: String
    let description: String?
    
    init(time: Date, title: String, description: String? = nil) {
        self.id = UUID()
        self.time = time
        self.title = title
        self.description = description
    }
}

struct ChatChart: Hashable {
    let title: String
    let data: [ChatDataPoint]
    let type: ChatChartType
}

struct ChatDataPoint: Hashable {
    let label: String
    let value: Double
    let date: Date
}

enum ChatChartType {
    case line
    case bar
    case pie
}

// Chat Actions
enum ChatAction {
    case selectOption(String)
    case viewDetails(String)
    case addEntry
    case editEntry(LogEntry)
    case deleteEntry(LogEntry)
    case generateMore
    case shareInsight(String)
}

// Chat Message
struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    let blocks: [ChatBlock]
    let isLoading: Bool
    
    init(
        id: UUID = UUID(),
        text: String = "",
        isFromUser: Bool,
        timestamp: Date = Date(),
        blocks: [ChatBlock] = [],
        isLoading: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.blocks = blocks
        self.isLoading = isLoading
    }
}