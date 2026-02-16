import SwiftUI

struct ChatBlockView: View {
    let block: ChatBlock
    var onAction: ((ChatAction) -> Void)?
    var onWorkoutTap: ((UUID) -> Void)?

    var body: some View {
        switch block.type {
        case .text:
            TextBlockView(payload: block.payload)
        case .metrics:
            MetricsBlockView(payload: block.payload)
        case .insights:
            InsightsBlockView(payload: block.payload)
        case .timeline:
            TimelineBlockView(payload: block.payload)
        case .recommendations:
            RecommendationsBlockView(payload: block.payload)
        case .question:
            QuestionBlockView(payload: block.payload, onAction: onAction)
        case .chart:
            ChartBlockView(payload: block.payload)
        }
    }
}

// MARK: - Text Block

private struct TextBlockView: View {
    let payload: ChatBlockPayload

    var body: some View {
        switch payload {
        case .text(let text):
            Text(text)
                .font(.body)
                .foregroundColor(Theme.textPrimary)
                .multilineTextAlignment(.leading)
        default:
            Text("Unsupported content")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Metrics Block

private struct MetricsBlockView: View {
    let payload: ChatBlockPayload

    var body: some View {
        switch payload {
        case .metrics(let metrics):
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(metrics) { metric in
                    MetricCardView(metric: metric)
                }
            }
        default:
            Text("No metrics available")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

private struct MetricCardView: View {
    let metric: ChatMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(metric.name)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(metric.value)
                .font(.title2)
                .fontWeight(.semibold)
            if let unit = metric.unit {
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Insights Block

private struct InsightsBlockView: View {
    let payload: ChatBlockPayload

    var body: some View {
        switch payload {
        case .insights(let insights):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(insights.enumerated()), id: \.offset) { _, insight in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(insight)
                            .font(.body)
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
        default:
            Text("No insights available")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Timeline Block

private struct TimelineBlockView: View {
    let payload: ChatBlockPayload

    var body: some View {
        switch payload {
        case .timeline(let events):
            VStack(alignment: .leading, spacing: 12) {
                ForEach(events) { event in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 8, height: 8)
                            .offset(y: 6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.body)
                                .fontWeight(.medium)
                            if let description = event.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(event.time, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
        default:
            Text("No timeline available")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Recommendations Block

private struct RecommendationsBlockView: View {
    let payload: ChatBlockPayload

    var body: some View {
        switch payload {
        case .recommendations(let recommendations):
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(recommendations.enumerated()), id: \.offset) { _, recommendation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text(recommendation)
                            .font(.body)
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
        default:
            Text("No recommendations available")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Question Block

private struct QuestionBlockView: View {
    let payload: ChatBlockPayload
    var onAction: ((ChatAction) -> Void)?

    var body: some View {
        switch payload {
        case .question(let question, let options):
            VStack(alignment: .leading, spacing: 12) {
                Text(question)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            onAction?(.selectOption(option))
                        }) {
                            Text(option)
                                .font(.body)
                                .foregroundColor(Theme.accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        default:
            Text("Invalid question format")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Chart Block

private struct ChartBlockView: View {
    let payload: ChatBlockPayload

    var body: some View {
        switch payload {
        case .chart(let chart):
            VStack(alignment: .leading, spacing: 12) {
                Text(chart.title)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                // Simple placeholder for chart
                Rectangle()
                    .fill(Theme.cardBackground)
                    .frame(height: 200)
                    .overlay(
                        Text("Chart: \(chart.title)")
                            .foregroundColor(.secondary)
                    )
            }
        default:
            Text("No chart data available")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}