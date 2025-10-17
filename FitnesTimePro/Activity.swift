import Foundation

struct Workout: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: WorkoutType
    var duration: TimeInterval
    var date: Date
}

enum WorkoutType: String, CaseIterable, Codable, Identifiable {
    case walking = "Walking"
    case running = "Running"
    case abs = "Abs"
    case pushups = "Push-ups"
    case pullups = "Pull-ups"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .walking: "figure.walk"
        case .running: "figure.run"
        case .abs: "figure.core.training"
        case .pushups: "figure.strengthtraining.traditional"
        case .pullups: "figure.pullups"
        }
    }
} 