import Foundation
import os

@MainActor
final class ChatService: ObservableObject {
    private static let logger = Logger(subsystem: "com.whussey.babytalk", category: "ChatService")
    
    @Published var isProcessing = false
    @Published var messages: [ChatMessage] = []
    
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    func sendMessage(_ text: String, babyProfile: BabyProfile?, recentLogs: [LogEntry]) async {
        let userMessage = ChatMessage(text: text, isFromUser: true)
        messages.append(userMessage)
        
        isProcessing = true
        defer { isProcessing = false }
        
        let apiKey = APIKeyProvider.resolvedKey
        guard !apiKey.isEmpty else {
            let errorMessage = ChatMessage(text: "Error: No API key available. Please check your settings.", isFromUser: false)
            messages.append(errorMessage)
            return
        }
        
        do {
            let response = try await getChatResponse(text, babyProfile: babyProfile, recentLogs: recentLogs)
            let assistantMessage = ChatMessage(text: response, isFromUser: false)
            messages.append(assistantMessage)
        } catch {
            Self.logger.error("Chat error: \(error)")
            let errorMessage = ChatMessage(text: "Sorry, I encountered an error. Please try again.", isFromUser: false)
            messages.append(errorMessage)
        }
    }
    
    private func getChatResponse(_ message: String, babyProfile: BabyProfile?, recentLogs: [LogEntry]) async throws -> String {
        let prompt = AIPromptBuilder.chatPrompt(message: message, babyProfile: babyProfile, recentLogs: recentLogs)
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(APIKeyProvider.resolvedKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        let requestBody = [
            "model": "gpt-4o",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ChatError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ChatError.invalidResponse
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func clearMessages() {
        messages.removeAll()
    }
}

enum ChatError: LocalizedError {
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Invalid response from chat API"
        case .apiError(let code, let message): "Chat API error (\(code)): \(message)"
        }
    }
}