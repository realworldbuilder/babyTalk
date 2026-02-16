import SwiftUI

struct RecordView: View {
    @Environment(LogStore.self) private var logStore
    @StateObject private var audioRecorder = AudioRecorderService()
    @StateObject private var transcriptionService = TranscriptionService()
    @StateObject private var aiService = AIProcessingService()
    
    @State private var recordedAudioURL: URL?
    @State private var transcriptionText = ""
    @State private var structuredEntry: LogEntry?
    @State private var isProcessing = false
    @State private var showingConfirmation = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Recording section
                    VStack(spacing: 20) {
                        Text("Record Your Entry")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Say something like:\n\"Fed the baby at 2am, nursed left side 15 minutes\"\n\"Diaper change, poop, 3:15am\"\n\"Baby slept from 10pm to 2am\"")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Record button
                        Button(action: toggleRecording) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(audioRecorder.isRecording ? Color.red : Color.blue)
                                        .frame(width: 120, height: 120)
                                    
                                    if audioRecorder.isRecording {
                                        Circle()
                                            .fill(Color.red.opacity(0.3))
                                            .frame(width: 140, height: 140)
                                            .scaleEffect(1.0 + sin(Date().timeIntervalSinceReferenceDate * 3) * 0.1)
                                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: audioRecorder.isRecording)
                                    }
                                    
                                    Image(systemName: audioRecorder.isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                                
                                if audioRecorder.isRecording {
                                    Text(String(format: "%.1fs", audioRecorder.recordingDuration))
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .disabled(isProcessing)
                        
                        if audioRecorder.isRecording {
                            Button("Stop Recording") {
                                stopRecording()
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                        }
                    }
                    
                    // Processing/Results section
                    if isProcessing {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Processing your recording...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 20)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    
                    if !transcriptionText.isEmpty && !isProcessing {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What I heard:")
                                .font(.headline)
                            
                            Text("\"\(transcriptionText)\"")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    if let entry = structuredEntry {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Structured Entry:")
                                .font(.headline)
                            
                            LogEntryPreview(entry: entry)
                            
                            HStack(spacing: 16) {
                                Button("Save Entry") {
                                    saveEntry()
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                                
                                Button("Try Again") {
                                    resetRecording()
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .navigationTitle("Record")
            .alert("Entry Saved", isPresented: $showingConfirmation) {
                Button("OK") {
                    resetRecording()
                }
            } message: {
                Text("Your entry has been saved to today's log.")
            }
        }
    }
    
    private func toggleRecording() {
        if audioRecorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        resetState()
        audioRecorder.startRecording()
    }
    
    private func stopRecording() {
        guard let audioURL = audioRecorder.stopRecording() else {
            errorMessage = "Failed to save recording"
            return
        }
        
        recordedAudioURL = audioURL
        processRecording(audioURL)
    }
    
    private func processRecording(_ audioURL: URL) {
        guard let baby = logStore.babyProfile else {
            errorMessage = "No baby profile found"
            return
        }
        
        isProcessing = true
        
        Task {
            // Step 1: Transcribe
            let transcriptionResult = await transcriptionService.transcribe(audioURL: audioURL)
            
            await MainActor.run {
                switch transcriptionResult {
                case .success(let transcript):
                    transcriptionText = transcript
                    
                    // Step 2: Structure into log entry
                    Task {
                        let structuredResult = await aiService.processVoiceToLogEntry(transcript, babyId: baby.id)
                        
                        await MainActor.run {
                            isProcessing = false
                            
                            switch structuredResult {
                            case .success(let entry):
                                structuredEntry = entry
                                errorMessage = nil
                            case .failure(let error):
                                errorMessage = "Failed to structure entry: \(error.localizedDescription)"
                            }
                        }
                    }
                    
                case .failure(let error):
                    isProcessing = false
                    errorMessage = "Transcription failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func saveEntry() {
        guard let entry = structuredEntry else { return }
        logStore.addLogEntry(entry)
        showingConfirmation = true
    }
    
    private func resetRecording() {
        resetState()
        audioRecorder.cleanup()
    }
    
    private func resetState() {
        recordedAudioURL = nil
        transcriptionText = ""
        structuredEntry = nil
        errorMessage = nil
        isProcessing = false
    }
}

struct LogEntryPreview: View {
    let entry: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: entry.type.icon)
                    .foregroundColor(colorForType(entry.type))
                
                Text(entry.type.displayName)
                    .font(.headline)
                
                Spacer()
                
                Text(entry.timeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.displaySummary)
                .font(.body)
            
            if !entry.notes.isEmpty {
                Text("Notes: \(entry.notes)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func colorForType(_ type: LogEntryType) -> Color {
        switch type {
        case .feeding: return .blue
        case .sleep: return .purple
        case .diaper: return .green
        case .note: return .gray
        }
    }
}

#Preview {
    RecordView()
        .environment(LogStore())
}