import SwiftUI

@main
struct BabyTalkApp: App {
    @State private var logStore = LogStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(logStore)
        }
    }
}