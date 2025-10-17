import SwiftUI

private struct SegmentTapEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct CustomSegmentedPicker<T: Hashable & Identifiable & CaseIterable & RawRepresentable>: View where T.RawValue == String, T.AllCases == [T] {
    @Binding var selection: T
    @Namespace private var activeSegmentNamespace
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(T.allCases) { option in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65, blendDuration: 0.5)) {
                                selection = option
                            }
                        }) {
                            Text(option.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .foregroundColor(selection == option ? AppTheme.accent : AppTheme.textSecondary)
                                .background(
                                    ZStack {
                                        if selection == option {
                                            Capsule()
                                                .fill(AppTheme.card)
                                                .shadow(color: AppTheme.accent.opacity(0.4), radius: 6, x: 0, y: 0)
                                                .overlay(Capsule().stroke(AppTheme.accent, lineWidth: 1.5))
                                                .matchedGeometryEffect(id: "active_segment", in: activeSegmentNamespace)
                                        }
                                    }
                                )
                        }
                        .buttonStyle(SegmentTapEffect())
                    }
                }
                .padding(.horizontal, 4)
                .frame(minWidth: geometry.size.width)
            }
        }
        .padding(.vertical, 4)
        .background(
            Capsule().fill(Color.black.opacity(0.25))
        )
        .frame(height: 48)
    }
} 