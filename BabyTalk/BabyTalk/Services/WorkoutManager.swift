import Foundation
import Observation

@Observable
@MainActor
class WorkoutManager {
    static let shared = WorkoutManager()
    
    var isActive: Bool = false
    var currentWorkout: Workout?
    var activeSession: WorkoutSession?
    var isProcessingMoment: Bool = false
    var workoutStore: SimpleWorkoutStore = SimpleWorkoutStore()
    
    private init() {}
    
    func startWorkout() {
        isActive = true
        currentWorkout = Workout(id: UUID(), name: "Baby Activity", startTime: Date())
        activeSession = WorkoutSession(id: UUID(), startedAt: Date())
    }
    
    func stopWorkout() {
        isActive = false
        currentWorkout = nil
        activeSession = nil
    }
    
    func endWorkout() {
        stopWorkout()
    }
    
    func addMoment(audioURL: URL, source: MomentSource) async {
        isProcessingMoment = true
        defer { isProcessingMoment = false }
        
        // Add moment to active session
        if activeSession != nil {
            let moment = Moment(
                id: UUID(),
                timestamp: Date(),
                transcript: "Audio recording",
                source: source,
                tags: [],
                confidence: 1.0
            )
            activeSession?.moments.append(moment)
        }
    }
}

struct Workout: Identifiable {
    let id: UUID
    let name: String
    let startTime: Date
    var endTime: Date?
}

// Simple workout store for compatibility
class SimpleWorkoutStore {
    var index: [WorkoutSessionIndex] = []
    
    func loadSession(id: UUID) -> WorkoutSession? {
        // Return nil for now - no sessions loaded
        return nil
    }
    
    func deleteSession(id: UUID) {
        index.removeAll { $0.id == id }
    }
    
    func saveSession(_ session: WorkoutSession) {
        // Add or update session in index
        let entry = WorkoutSessionIndex(from: session)
        
        // Remove existing entry with same id
        index.removeAll { $0.id == session.id }
        
        // Add updated entry
        index.append(entry)
    }
}