import Foundation
import os

@MainActor
final class AIProcessingService: ObservableObject {
    private static let logger = Logger(subsystem: "com.whussey.babytalk", category: "AIProcessingService")
    
    @Published var isProcessing = false
    
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    func processVoiceToLogEntry(_ transcript: String, babyId: UUID) async -> Result<LogEntry, Error> {
        isProcessing = true
        defer { isProcessing = false }
        
        let apiKey = APIKeyProvider.resolvedKey
        guard !apiKey.isEmpty else {
            return .failure(AIProcessingError.noAPIKey)
        }
        
        let prompt = AIPromptBuilder.structureVoicePrompt(transcript: transcript)
        
        do {
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 60
            
            let requestBody = [
                "model": "gpt-4o",
                "messages": [
                    ["role": "user", "content": prompt]
                ],
                "temperature": 0.1,
                "max_tokens": 800
            ] as [String: Any]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(AIProcessingError.invalidResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                Self.logger.error("OpenAI API error \(httpResponse.statusCode): \(errorBody)")
                return .failure(AIProcessingError.apiError(statusCode: httpResponse.statusCode, message: errorBody))
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                return .failure(AIProcessingError.invalidResponse)
            }
            
            // Parse the JSON response
            guard let responseData = content.data(using: .utf8),
                  let structuredResponse = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
                return .failure(AIProcessingError.invalidStructure)
            }
            
            // Create LogEntry from structured response
            let logEntry = try parseStructuredResponse(structuredResponse, babyId: babyId)
            
            return .success(logEntry)
            
        } catch let error as AIProcessingError {
            return .failure(error)
        } catch {
            Self.logger.error("AI processing failed: \(error)")
            return .failure(error)
        }
    }
    
    private func parseStructuredResponse(_ response: [String: Any], babyId: UUID) throws -> LogEntry {
        guard let typeString = response["type"] as? String,
              let type = LogEntryType(rawValue: typeString) else {
            throw AIProcessingError.invalidStructure
        }
        
        // Parse timestamp
        let timestamp: Date
        if let timestampString = response["timestamp"] as? String {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else {
            timestamp = Date()
        }
        
        let notes = response["notes"] as? String ?? ""
        let entry = LogEntry(babyId: babyId, timestamp: timestamp, type: type, notes: notes)
        
        // Parse type-specific details
        switch type {
        case .feeding:
            if let feedingData = response["feeding"] as? [String: Any] {
                let methodString = feedingData["method"] as? String ?? "bottle"
                let method = FeedingMethod(rawValue: methodString) ?? .bottle
                let amount = feedingData["amount"] as? Double
                let duration = feedingData["duration"] as? Int
                let unit = feedingData["unit"] as? String
                
                entry.feedingDetails = FeedingDetails(
                    method: method,
                    amount: amount,
                    duration: duration,
                    unit: unit
                )
            }
            
        case .sleep:
            if let sleepData = response["sleep"] as? [String: Any] {
                let startTime: Date
                if let startTimeString = sleepData["startTime"] as? String {
                    let formatter = ISO8601DateFormatter()
                    startTime = formatter.date(from: startTimeString) ?? Date()
                } else {
                    startTime = Date()
                }
                
                let endTime: Date?
                if let endTimeString = sleepData["endTime"] as? String {
                    let formatter = ISO8601DateFormatter()
                    endTime = formatter.date(from: endTimeString)
                } else {
                    endTime = nil
                }
                
                let totalMinutes = sleepData["totalMinutes"] as? Int
                
                entry.sleepDetails = SleepDetails(
                    startTime: startTime,
                    endTime: endTime,
                    totalMinutes: totalMinutes
                )
            }
            
        case .diaper:
            if let diaperData = response["diaper"] as? [String: Any] {
                let wet = diaperData["wet"] as? Bool ?? false
                let dirty = diaperData["dirty"] as? Bool ?? false
                
                entry.diaperDetails = DiaperDetails(wet: wet, dirty: dirty)
            }
            
        case .note:
            // Notes are already handled in the base entry
            break
        }
        
        return entry
    }
}

enum AIProcessingError: LocalizedError {
    case noAPIKey
    case invalidResponse
    case invalidStructure
    case apiError(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey: "No API key available"
        case .invalidResponse: "Invalid response from OpenAI API"
        case .invalidStructure: "Unable to parse structured response"
        case .apiError(let code, let message): "OpenAI API error (\(code)): \(message)"
        }
    }
}