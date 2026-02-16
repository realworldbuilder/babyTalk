import Foundation

@Observable
class StoryReadTracker {
    static let shared = StoryReadTracker()
    
    private let userDefaults = UserDefaults.standard
    private let readStoriesKey = "ReadStories"
    
    private var readStories: Set<String> = []
    
    private init() {
        loadReadStories()
    }
    
    func isUnread(_ storyIdentifier: String, contentHash: Int) -> Bool {
        let key = "\(storyIdentifier)_\(contentHash)"
        return !readStories.contains(key)
    }
    
    func markAsRead(_ storyIdentifier: String, contentHash: Int) {
        let key = "\(storyIdentifier)_\(contentHash)"
        readStories.insert(key)
        saveReadStories()
    }
    
    func markAsUnread(_ storyIdentifier: String, contentHash: Int) {
        let key = "\(storyIdentifier)_\(contentHash)"
        readStories.remove(key)
        saveReadStories()
    }
    
    private func loadReadStories() {
        if let data = userDefaults.data(forKey: readStoriesKey),
           let stories = try? JSONDecoder().decode(Set<String>.self, from: data) {
            readStories = stories
        }
    }
    
    private func saveReadStories() {
        if let data = try? JSONEncoder().encode(readStories) {
            userDefaults.set(data, forKey: readStoriesKey)
        }
    }
}