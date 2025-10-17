import SwiftUI

struct FitnessCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.card)
                    .shadow(color: AppTheme.shadow1, radius: 10, x: 0, y: 6)
                    .shadow(color: AppTheme.shadow2.opacity(0.18), radius: 2, x: 0, y: 1)
            )
            .padding(.vertical, 6)
    }
} 