import SwiftUI

struct CustomInputField: View {
    @Binding var value: String
    var placeholder: String = "Enter value"
    var icon: String = "pencil"
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.accent)
                .shadow(color: AppTheme.accent.opacity(0.5), radius: 4, x: 0, y: 2)
            TextField(placeholder, text: $value)
                .keyboardType(.default)
                .font(.title2.weight(.semibold))
                .foregroundColor(AppTheme.text)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 22)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.background.opacity(0.85),
                                Color.white.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: AppTheme.shadow1, radius: 12, x: 0, y: 6)
                    .shadow(color: AppTheme.shadow2.opacity(0.3), radius: 2, x: 0, y: 1)
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 60, height: 30)
                    .offset(x: -40, y: -28)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(AppTheme.accent, lineWidth: 2)
        )
        .padding(.horizontal, 8)
    }
} 