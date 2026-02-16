import SwiftUI

struct ChatView: View {
    @Environment(LogStore.self) private var logStore
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                // Chat header
                VStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Baby Talk AI Assistant")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Ask questions about baby care, feeding patterns, sleep schedules, and more!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message if no messages
                            if chatService.messages.isEmpty {
                                VStack(spacing: 16) {
                                    Text("👋 Hi there!")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Text("I'm here to help with baby care questions and insights about your baby's patterns. I can help with:")
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        QuickQuestionButton(
                                            text: "Is my baby eating enough?",
                                            action: { sendQuickQuestion("Is my baby eating enough?") }
                                        )
                                        
                                        QuickQuestionButton(
                                            text: "How's the sleep pattern this week?",
                                            action: { sendQuickQuestion("How's the sleep pattern this week?") }
                                        )
                                        
                                        QuickQuestionButton(
                                            text: "Tips for better sleep",
                                            action: { sendQuickQuestion("What are some tips for helping my baby sleep better?") }
                                        )
                                        
                                        QuickQuestionButton(
                                            text: "Normal feeding frequency",
                                            action: { sendQuickQuestion("How often should my baby be feeding?") }
                                        )
                                    }
                                    
                                    Text("⚠️ Remember: I'm not a medical professional. Always consult your pediatrician for medical concerns.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.top)
                                }
                                .padding()
                            }
                            
                            // Chat messages
                            ForEach(chatService.messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                            
                            // Processing indicator
                            if chatService.isProcessing {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: chatService.messages.count) { _, _ in
                        // Scroll to bottom when new message arrives
                        withAnimation {
                            if let lastMessage = chatService.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message input
                HStack {
                    TextField("Ask a question...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatService.isProcessing)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        chatService.clearMessages()
                    }
                    .disabled(chatService.messages.isEmpty)
                }
            }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        isTextFieldFocused = false
        
        let recentEntries = getRecentLogEntries()
        
        Task {
            await chatService.sendMessage(text, babyProfile: logStore.babyProfile, recentLogs: recentEntries)
        }
    }
    
    private func sendQuickQuestion(_ question: String) {
        messageText = question
        sendMessage()
    }
    
    private func getRecentLogEntries() -> [LogEntry] {
        let calendar = Calendar.current
        var recentEntries: [LogEntry] = []
        
        // Get entries from last 7 days
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let dailyLog = logStore.dailyLog(for: date)
            recentEntries.append(contentsOf: dailyLog.sortedEntries)
        }
        
        // Sort by most recent first and limit to 20 entries
        return Array(recentEntries.sorted { $0.timestamp > $1.timestamp }.prefix(20))
    }
}

// ChatMessageView is defined in ChatMessageView.swift

struct QuickQuestionButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "arrow.right.circle")
                    .font(.subheadline)
            }
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ChatView()
        .environment(LogStore())
}