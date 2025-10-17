import SwiftUI

struct AppTheme {
    static let background = Color(hex: "#1C1C2E")
    static let accent = Color(hex: "#00C7BE")
    static let accentDark = Color(hex: "#008C86")
    static let shadow1 = Color.black.opacity(0.4)
    static let shadow2 = Color.black.opacity(0.6)
    static let text = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let card = Color.white.opacity(0.05)
    static let cardStroke = Color.white.opacity(0.1)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 