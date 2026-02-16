import Foundation
import Observation

@Observable
@MainActor
class InsightsService {
    static let shared = InsightsService()
    
    var insights: [Insight] = []
    var stories: [InsightStory] = []
    var dashboardMetrics: [DashboardMetric] = []
    var isGenerating: Bool = false
    
    private init() {}
    
    func generateInsights(for logs: [LogEntry], babyProfile: BabyProfile?) async {
        isGenerating = true
        defer { isGenerating = false }
        
        // Placeholder for insight generation
        let insight = Insight(
            id: UUID(),
            title: "Daily Pattern",
            content: "Baby had a good day with regular feeding patterns.",
            date: Date(),
            type: "pattern"
        )
        insights.append(insight)
    }
}

struct Insight: Identifiable {
    let id: UUID
    let title: String
    let content: String
    let date: Date
    let type: String
}