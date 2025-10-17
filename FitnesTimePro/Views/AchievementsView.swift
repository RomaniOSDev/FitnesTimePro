import SwiftUI

struct AchievementsView: View {
    @AppStorage("activityHistory") private var activityHistoryData: Data = Data()
    @AppStorage("dailyActivityGoal") private var dailyGoal: TimeInterval = 3600
    
    private var history: [Workout] {
        (try? JSONDecoder().decode([Workout].self, from: activityHistoryData)) ?? []
    }
    
    private let achievements: [Achievement] = [
        Achievement(
            id: "first_workout",
            title: "First Step",
            description: "Log your very first workout",
            icon: "sparkles"
        ),
        Achievement(
            id: "30_min_workout",
            title: "Endurance",
            description: "Complete a single 30-minute workout",
            icon: "timer"
        ),
        Achievement(
            id: "3_day_streak",
            title: "Consistency",
            description: "Meet your daily goal 3 days in a row",
            icon: "flame.fill"
        )
    ]
    
    private func isUnlocked(_ achievementId: String) -> Bool {
        switch achievementId {
        case "first_workout":
            return !history.isEmpty
        case "30_min_workout":
            return history.contains { $0.duration >= 1800 }
        case "3_day_streak":
            return checkStreak(days: 3)
        default:
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BreathingBackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Achievements")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.text)
                            .padding(.top)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                            ForEach(achievements) { achievement in
                                AchievementCard(achievement: achievement, isUnlocked: isUnlocked(achievement.id))
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                .navigationBarHidden(true)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(AppTheme.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
    }
    
    private func checkStreak(days: Int) -> Bool {
        let groupedByDay = Dictionary(grouping: history) { workout in
            Calendar.current.startOfDay(for: workout.date)
        }
        
        let dailyTotals = groupedByDay.mapValues { workouts in
            workouts.reduce(0) { $0 + $1.duration }
        }
        
        guard dailyTotals.count >= days else { return false }
        
        let sortedDays = dailyTotals.keys.sorted { $0 > $1 }
        
        var consecutiveDays = 0
        var previousDay = Date()
        
        for (index, day) in sortedDays.enumerated() {
            if index > 0 {
                if let diff = Calendar.current.dateComponents([.day], from: day, to: previousDay).day, diff != 1 {
                    consecutiveDays = 0
                }
            }
            
            if dailyTotals[day, default: 0] >= dailyGoal {
                consecutiveDays += 1
                if consecutiveDays >= days {
                    return true
                }
            } else {
                consecutiveDays = 0
            }
            previousDay = day
        }
        
        return false
    }
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: achievement.icon)
                .font(.system(size: 40))
                .foregroundColor(isUnlocked ? AppTheme.accent : AppTheme.textSecondary)
                .shadow(color: isUnlocked ? AppTheme.accent.opacity(0.6) : .clear, radius: 8)
            
            VStack(alignment: .center, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(AppTheme.text)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if isUnlocked {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Unlocked")
                }
                .font(.caption.bold())
                .foregroundColor(AppTheme.accent)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(AppTheme.accent.opacity(0.15))
                .clipShape(Capsule())
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                    Text("Locked")
                }
                .font(.caption.bold())
                .foregroundColor(AppTheme.textSecondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(AppTheme.textSecondary.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(20)
        .background(
            BlurView(style: .systemUltraThinMaterialDark)
                .background(AppTheme.card.opacity(0.6))
        )
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(isUnlocked ? AppTheme.accent.opacity(0.5) : AppTheme.cardStroke, lineWidth: 1.5)
        )
        .scaleEffect(isVisible ? 1 : 0.9)
        .opacity(isVisible ? (isUnlocked ? 1.0 : 0.6) : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                isVisible = true
            }
        }
    }
} 