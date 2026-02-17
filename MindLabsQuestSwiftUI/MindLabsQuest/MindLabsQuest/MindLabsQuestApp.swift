import SwiftUI

@main
struct MindLabsQuestApp: App {
    @StateObject private var gameManager = GameManager()
    @StateObject private var notificationManager = NotificationManager.shared
    
    var achievementManager: AchievementManager {
        gameManager.achievementManager
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(notificationManager)
                .onAppear {
                    // Schedule daily quest reminder for 9 AM
                    notificationManager.scheduleDailyQuestReminder(at: 9)
                    // Schedule streak reminder for 8 PM
                    notificationManager.scheduleStreakReminder()
                }
        }
    }
}