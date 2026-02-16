import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    var onAction: ((ChatAction) -> Void)?
    var onWorkoutTap: ((UUID) -> Void)?

    var body: some View {
        if message.isLoading {
            HStack {
                TypingIndicator()
                Spacer()
            }
        } else if message.isFromUser {
            UserBubble(message: message)
        } else {
            AssistantMessage(message: message, onAction: onAction, onWorkoutTap: onWorkoutTap)
        }
    }
}

// MARK: - User Bubble

private struct UserBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            Spacer()
            Text(getMessageText(from: message))
                .font(.body)
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: Theme.radiusMedium))
        }
    }
    
    private func getMessageText(from message: ChatMessage) -> String {
        if let firstBlock = message.blocks.first {
            switch firstBlock.payload {
            case .text(let text):
                return text
            default:
                break
            }
        }
        return message.text
    }
}

// MARK: - Assistant Message

private struct AssistantMessage: View {
    let message: ChatMessage
    var onAction: ((ChatAction) -> Void)?
    var onWorkoutTap: ((UUID) -> Void)?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(message.blocks) { block in
                    ChatBlockView(block: block, onAction: onAction, onWorkoutTap: onWorkoutTap)
                }
            }
            Spacer(minLength: 40)
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var phase = 0.0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Theme.textSecondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(dotScale(for: index))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: phase
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: Theme.radiusMedium))
        .onAppear { phase = 1.0 }
    }

    private func dotScale(for index: Int) -> CGFloat {
        let offset = Double(index) * 0.15
        let t = (phase + offset).truncatingRemainder(dividingBy: 1.0)
        return 0.5 + 0.5 * sin(t * .pi)
    }
}
