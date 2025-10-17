import SwiftUI
import StoreKit
import SafariServices

struct SettingsView: View {
    @AppStorage("activityHistory") private var activityHistoryData: Data = Data()
    @AppStorage("dailyActivityGoal") private var dailyGoal: TimeInterval = 3600

    @State private var showResetAlert = false
    @State private var showPrivacyPolicy = false
    
    private let goalOptions: [TimeInterval] = [1800, 3600, 5400, 7200, 9000, 10800]

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Settings")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.text)
                            .padding(.top)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "target")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(width: 30)
                                Text("Daily Goal")
                                    .font(.title3.bold())
                                    .foregroundColor(AppTheme.text)
                                Spacer()
                                Text(dailyGoal.formattedAsHours())
                                    .font(.headline)
                                    .foregroundColor(AppTheme.accent)
                            }
                            Picker("Daily Activity Goal", selection: $dailyGoal) {
                                ForEach(goalOptions, id: \.self) { option in
                                    Text(option.formattedAsHours()).tag(option)
                                }
                            }
                            .pickerStyle(.wheel)
                            .colorScheme(.dark)
                            .frame(height: 100)
                            .clipped()
                        }
                        .padding([.horizontal, .top])
                        .padding(.bottom, 10)
                        .backgroundCard()

                        VStack {
                            LinkRow(icon: "lock.shield.fill", title: "Privacy Policy") {
                                showPrivacyPolicy = true
                            }
                            Divider().background(AppTheme.cardStroke.opacity(0.5))
                            LinkRow(icon: "star.fill", title: "Rate App") {
                                rateApp()
                            }
                        }
                        .padding()
                        .backgroundCard()
                        
                        VStack {
                            Button(action: { showResetAlert = true }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text("Reset All Data")
                                }
                                .font(.headline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .padding()
                        .backgroundCard()

                        Spacer()
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
                .background(BreathingBackgroundView())
                .edgesIgnoringSafeArea(.all)
                .navigationBarHidden(true)
            }
            .alert("Reset all data?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    activityHistoryData = Data()
                    dailyGoal = 3600
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset your activity goal and clear all your history.")
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                SafariView(url: URL(string: "https://www.apple.com")!)
                    .ignoresSafeArea()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

fileprivate extension View {
    func backgroundCard() -> some View {
        self
            .background(
                BlurView(style: .systemUltraThinMaterialDark)
                    .background(AppTheme.card.opacity(0.5))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.cardStroke, lineWidth: 1)
            )
    }
}

fileprivate struct LinkRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.accent)
                Text(title)
                    .foregroundColor(AppTheme.text)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

fileprivate extension TimeInterval {
    func formattedAsHours() -> String {
        let hours = self / 3600
        if hours == floor(hours) {
            return "\(Int(hours))h"
        }
        return String(format: "%.1fh", hours)
    }
}

fileprivate struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 