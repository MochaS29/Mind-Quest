import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            Group {
                if !gameManager.isCharacterCreated {
                    CharacterCreationView()
                } else {
                    MainTabView()
                }
            }
            .mindLabsNavigationBar()
            .mindLabsTabBar()
            
            // Quest completion animation overlay
            if gameManager.showQuestCompletionAnimation, let quest = gameManager.completedQuest {
                QuestCompletionView(
                    quest: quest,
                    xpEarned: gameManager.lastXPEarned,
                    goldEarned: gameManager.lastGoldEarned,
                    onDismiss: {
                        gameManager.showQuestCompletionAnimation = false
                        gameManager.completedQuest = nil
                    }
                )
                .zIndex(90)
                .transition(.opacity.combined(with: .scale))
            }
            
            // Level up animation overlay (shows after quest completion)
            if gameManager.showLevelUpAnimation {
                LevelUpView(
                    newLevel: gameManager.newLevel,
                    onDismiss: {
                        gameManager.showLevelUpAnimation = false
                    }
                )
                .zIndex(100)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        TabView(selection: $gameManager.currentView) {
            DashboardView()
                .tabItem {
                    Label("Quest", systemImage: "house.fill")
                }
                .tag(GameManager.AppView.dashboard)
            
            QuestsView()
                .tabItem {
                    Label("Adventures", systemImage: "target")
                }
                .tag(GameManager.AppView.quests)
            
            RoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "list.bullet.rectangle")
                }
                .tag(GameManager.AppView.routines)
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(GameManager.AppView.calendar)
            
            DataAnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(GameManager.AppView.analytics)
            
            PomodoroTimerView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
                .tag(GameManager.AppView.timer)
            
            CommunityHubView()
                .tabItem {
                    Label("Community", systemImage: "person.3.fill")
                }
                .tag(GameManager.AppView.social)
            
            CharacterView()
                .tabItem {
                    Label("Character", systemImage: "person.fill")
                }
                .tag(GameManager.AppView.character)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(GameManager.AppView.settings)
        }
        .accentColor(.mindLabsPurple)
        .alert("Streak Update! 🔥", isPresented: $gameManager.showStreakMessage) {
            Button("Awesome!") {
                gameManager.showStreakMessage = false
            }
        } message: {
            Text(gameManager.streakMessage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameManager())
    }
}