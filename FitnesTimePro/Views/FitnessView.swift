import SwiftUI
import Combine

enum TimerMode: String, CaseIterable, Identifiable {
    case stopwatch = "Stopwatch"
    case timer = "Timer"
    
    var id: Self { self }
}

struct FitnessView: View {
    @AppStorage("dailyActivityGoal") private var dailyGoal: TimeInterval = 3600
    @AppStorage("activityHistory") private var activityHistoryData: Data = Data()
    
    @State private var selectedWorkout: WorkoutType = .walking
    @State private var duration: TimeInterval = 0
    @State private var isTimerRunning = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var timerMode: TimerMode = .stopwatch
    @State private var countdownHours = 0
    @State private var countdownMinutes = 10
    
    @State private var particleKey = UUID()
    @State private var showParticles = false
    @State private var isViewVisible = false
    @State private var isEditingCountdown = false
    
    private var countdownDuration: TimeInterval {
        TimeInterval(countdownHours * 3600 + countdownMinutes * 60)
    }
    
    private var todaysWorkouts: [Workout] {
        let allWorkouts: [Workout] = (try? JSONDecoder().decode([Workout].self, from: activityHistoryData)) ?? []
        return allWorkouts.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var totalTimeToday: TimeInterval {
        todaysWorkouts.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        ZStack {
            BreathingBackgroundView()
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    headerView
                        .padding(.top, geometry.safeAreaInsets.top)
                        .padding(.bottom, geometry.size.height * 0.01)
                    
                    ProgressCircle(
                        progress: totalTimeToday / dailyGoal,
                        color: AppTheme.accent
                    )
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                    
                    Spacer()
                    
                    timerCardView(geometry: geometry)
                    
                    Spacer().frame(height: geometry.size.height * 0.12)
                }
                .padding(.horizontal)
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 10)
            }
            .edgesIgnoringSafeArea(.bottom)
            
            if showParticles {
                GeometryReader { geo in
                    ParticleEffectView(
                        center: CGPoint(x: geo.size.width / 2, y: geo.size.height - 150),
                        color: AppTheme.accent
                    )
                    .id(particleKey)
                }
            }
        }
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }
            
            if timerMode == .stopwatch {
                duration += 1
            } else {
                if duration > 0 {
                    duration -= 1
                } else {
                    isTimerRunning = false
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    showParticles = true
                    particleKey = UUID()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showParticles = false
                    }
                }
            }
        }
        .onAppear {
            setupTimer()
            if timerMode == .timer {
                duration = countdownDuration
            }
            isViewVisible = true
        }
        .onDisappear(perform: cancelTimer)
        .onChange(of: timerMode) { _ in
            isTimerRunning = false
            isEditingCountdown = false
            if timerMode == .stopwatch {
                duration = 0
            } else {
                duration = countdownDuration
            }
        }
        .onChange(of: countdownHours) { _ in
            if timerMode == .timer && !isTimerRunning {
                duration = countdownDuration
            }
        }
        .onChange(of: countdownMinutes) { _ in
            if timerMode == .timer && !isTimerRunning {
                duration = countdownDuration
            }
        }
        .minimumScaleFactor(0.8)
    }
    
    private var headerView: some View {
        VStack {
            Text("Today's Activity")
                .font(.largeTitle.bold())
                .foregroundColor(AppTheme.text)
                .minimumScaleFactor(0.8)
            Text(timeFormatted(totalTimeToday, full: true))
                .font(.title2)
                .foregroundColor(AppTheme.textSecondary)
                .minimumScaleFactor(0.8)
        }
    }
    
    private func timerCardView(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.025) {
            CustomSegmentedPicker(selection: $selectedWorkout)
            
            CustomSegmentedPicker(selection: $timerMode)

            if isEditingCountdown {
                HStack(spacing: 0) {
                    Picker("Hours", selection: $countdownHours) {
                        ForEach(0..<24) { Text("\($0)h") }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    Picker("Minutes", selection: $countdownMinutes) {
                        ForEach(0..<60) { Text("\($0)m") }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.black.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(height: geometry.size.height * 0.16)
                .clipped()
                .colorScheme(.dark)
                .transition(.scale.animation(.spring()))
            } else {
                Text(timeFormatted(duration))
                    .font(.system(size: geometry.size.width * 0.15, weight: .bold))
                    .monospacedDigit()
                    .foregroundColor(AppTheme.text)
                    .minimumScaleFactor(0.6)
                    .onTapGesture {
                        if timerMode == .timer && !isTimerRunning {
                            withAnimation(.spring()) {
                                isEditingCountdown = true
                            }
                        }
                    }
            }
            
            timerControls(geometry: geometry)
        }
        .padding(geometry.size.width * 0.06)
        .background(
            BlurView(style: .systemUltraThinMaterialDark)
                .background(AppTheme.card)
        )
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .stroke(AppTheme.cardStroke, lineWidth: 1)
        )
    }
    
    private func timerControls(geometry: GeometryProxy) -> some View {
        let buttonSize = geometry.size.width * 0.12
        let playButtonSize = geometry.size.width * 0.18

        return Group {
            if isEditingCountdown {
                Button(action: {
                    withAnimation(.spring()) {
                        isEditingCountdown = false
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.title.bold())
                        .frame(width: playButtonSize, height: playButtonSize)
                        .background(AppTheme.accent)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.accent.opacity(0.6), radius: 10, y: 5)
                }
                .foregroundColor(AppTheme.text)
            } else {
                HStack(spacing: 30) {
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .frame(width: buttonSize, height: buttonSize)
                            .background(AppTheme.card.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .opacity(isTimerRunning || duration == 0 ? 0.5 : 1)
                    .scaleEffect(isTimerRunning || duration == 0 ? 0.8 : 1)
                    .disabled(isTimerRunning || duration == 0)
                    .animation(.spring(), value: isTimerRunning || duration == 0)

                    Button(action: toggleTimer) {
                        Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                            .font(.largeTitle)
                            .frame(width: playButtonSize, height: playButtonSize)
                            .background(isTimerRunning ? Color.orange : AppTheme.accent)
                            .clipShape(Circle())
                            .shadow(color: isTimerRunning ? .orange.opacity(0.6) : AppTheme.accent.opacity(0.6), radius: isTimerRunning ? 20 : 10, y: isTimerRunning ? 15 : 5)
                            .animation(.easeInOut, value: isTimerRunning)
                    }
                    
                    Button(action: saveWorkout) {
                        Image(systemName: "checkmark")
                            .font(.title3.bold())
                            .frame(width: buttonSize, height: buttonSize)
                            .background(AppTheme.card.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .opacity(isTimerRunning || duration == 0 ? 0.5 : 1)
                    .scaleEffect(isTimerRunning || duration == 0 ? 0.8 : 1)
                    .disabled(isTimerRunning || duration == 0)
                    .animation(.spring(), value: isTimerRunning || duration == 0)
                }
                .foregroundColor(AppTheme.text)
            }
        }
    }
    
    private func setupTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    private func cancelTimer() {
        timer.upstream.connect().cancel()
    }

    private func toggleTimer() {
        withAnimation {
            isEditingCountdown = false
            if !isTimerRunning {
                if timerMode == .timer && duration <= 0 {
                    duration = countdownDuration
                    if duration <= 0 { return }
                }
            }
            isTimerRunning.toggle()
        }
    }
    
    private func resetTimer() {
        withAnimation(.spring()) {
            isTimerRunning = false
            if timerMode == .stopwatch {
                duration = 0
            } else {
                duration = countdownDuration
            }
        }
    }
    
    private func saveWorkout() {
        let timeToSave: TimeInterval
        if timerMode == .stopwatch {
            timeToSave = duration
        } else {
            timeToSave = countdownDuration - duration
        }
        
        guard timeToSave >= 1 else { return }

        let newWorkout = Workout(name: selectedWorkout, duration: timeToSave, date: Date())
        var allWorkouts: [Workout] = (try? JSONDecoder().decode([Workout].self, from: activityHistoryData)) ?? []
        allWorkouts.append(newWorkout)
        
        if let data = try? JSONEncoder().encode(allWorkouts) {
            activityHistoryData = data
        }
        
        showParticles = true
        particleKey = UUID()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showParticles = false
        }
        
        withAnimation(.spring()) {
            resetTimer()
        }
    }
    
    private func timeFormatted(_ totalSeconds: TimeInterval, full: Bool = false) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        if full {
            return "\(hours)h \(minutes)m \(seconds)s"
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Progress Circle
struct ProgressCircle: View {
    var progress: Double
    var color: Color
    var lineWidthFraction: CGFloat = 0.08

    var body: some View {
        GeometryReader { geometry in
            let lineWidth = geometry.size.width * lineWidthFraction
            ZStack {
                // Background ring
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(AppTheme.card.opacity(0.8))
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270))
                    .shadow(color: color.opacity(0.5), radius: 15, y: 10)
                    .animation(.linear(duration: 1.0), value: progress)
                
                // Percentage Text
                if progress > 0.001 {
                    Text(String(format: "%.0f%%", min(progress, 1.0) * 100))
                        .font(.system(size: geometry.size.width * 0.25, weight: .bold))
                        .foregroundColor(AppTheme.text)
                        .minimumScaleFactor(0.5)
                        .transition(.scale.animation(.spring(response: 0.4, dampingFraction: 0.6)))
                }
            }
        }
    }
}

// MARK: - Fitness Background
struct FitnessBackground: View {
    var body: some View {
        AppTheme.background
            .edgesIgnoringSafeArea(.all)
    }
} 
