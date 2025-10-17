import SwiftUI


struct HistoryView: View {
    @AppStorage("activityHistory") private var activityHistoryData: Data = Data()
    
    private var history: [Workout] {
        (try? JSONDecoder().decode([Workout].self, from: activityHistoryData)) ?? []
    }
    
    private var groupedHistory: [Date: [Workout]] {
        Dictionary(grouping: history) { workout in
            Calendar.current.startOfDay(for: workout.date)
        }
    }
    
    private var sortedDays: [Date] {
        groupedHistory.keys.sorted { $0 > $1 }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BreathingBackgroundView()
                
                if history.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text("No History Yet")
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.text)
                        
                        Text("Log your first workout to see your progress here.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(sortedDays, id: \.self) { day in
                                DayHistoryCard(day: day, workouts: groupedHistory[day] ?? [])
                                    .drawingGroup()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("History")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct DayHistoryCard: View {
    let day: Date
    let workouts: [Workout]
    @State private var isVisible = false
    
    private var totalDuration: TimeInterval {
        workouts.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day, style: .date)
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.text)
                Spacer()
                Text(totalDuration.formattedForHistory())
                    .font(.headline)
                    .foregroundColor(AppTheme.accent)
            }
            
            Divider().background(AppTheme.cardStroke)
            
            ForEach(workouts) { workout in
                WorkoutHistoryRow(workout: workout)
            }
        }
        .padding()
        .background(
            BlurView(style: .systemUltraThinMaterialDark)
                .background(AppTheme.card)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.cardStroke, lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                isVisible = true
            }
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Image(systemName: workout.name.icon)
                .font(.headline)
                .foregroundColor(AppTheme.accent)
                .frame(width: 30)
            
            Text(workout.name.rawValue)
                .font(.headline)
                .foregroundColor(AppTheme.text)
            
            Spacer()
            
            Text(workout.duration.formattedForHistory())
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

extension TimeInterval {
    func formattedForHistory() -> String {
        let totalSeconds = Int(self)
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return "\(seconds)s"
        }
    }
}

struct ActivityName: Codable {
    let rawValue: String
    let icon: String
} 

