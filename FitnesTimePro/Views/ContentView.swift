//

import SwiftUI

struct ContentView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.card.opacity(0.5))
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .black

        // Set color for unselected tabs
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(AppTheme.textSecondary)]
        
        // Set color for selected tab
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(AppTheme.accent)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            FitnessView()
                .tabItem {
                    Label("Fitness", systemImage: "flame.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            
            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "trophy.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(AppTheme.accent)
    }
}

#Preview {
    ContentView()
} 
