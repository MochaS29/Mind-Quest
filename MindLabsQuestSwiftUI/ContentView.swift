import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        Group {
            if !gameManager.isCharacterCreated {
                CharacterCreationView()
            } else {
                MainTabView()
            }
        }
        .mindLabsNavigationBar()
        .mindLabsTabBar()
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
            
            StandaloneTimerView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }
                .tag(GameManager.AppView.timer)
            
            CharacterView()
                .tabItem {
                    Label("Character", systemImage: "person.fill")
                }
                .tag(GameManager.AppView.character)
        }
        .accentColor(.mindLabsPurple)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameManager())
    }
}