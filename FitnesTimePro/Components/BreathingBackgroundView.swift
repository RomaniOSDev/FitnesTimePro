import SwiftUI

struct BreathingBackgroundView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            AppTheme.background.edgesIgnoringSafeArea(.all)

            Circle()
                .fill(AppTheme.accent.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .scaleEffect(isAnimating ? 1.5 : 0.8)
                .offset(x: -100, y: -200)

            Circle()
                .fill(AppTheme.accent.opacity(0.2))
                .frame(width: 400, height: 400)
                .blur(radius: 120)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .offset(x: 100, y: 150)
            
            Circle()
                .fill(AppTheme.accentDark.opacity(0.3))
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .scaleEffect(isAnimating ? 1.0 : 1.3)
                .offset(x: 50, y: -50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
} 