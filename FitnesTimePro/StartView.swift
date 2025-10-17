//
//  StartView.swift
//  FitnesTimePro
//
//  Created by Роман Главацкий on 14.10.2025.
//

import SwiftUI

struct StartView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    var body: some View {
        if !hasSeenOnboarding {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}

#Preview {
    StartView()
}
