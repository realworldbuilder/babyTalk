import SwiftUI

@main
struct BabyOpsApp: App {
    @State private var logStore = LogStore()
    @State private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(logStore)
                .environment(themeManager)
        }
    }
}