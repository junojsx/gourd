//
//  OnboardingFlow.swift
//  gourd
//
//  Root container for the 6-screen onboarding flow (5 value screens + paywall).
//  Uses a paged TabView for the swipe-through feel.
//

import SwiftUI

struct OnboardingFlow: View {
    @State private var currentStep: Int = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            // Ambient background blobs
            GeometryReader { geo in
                Circle()
                    .fill(Color.green600.opacity(0.18))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: geo.size.width - 150, y: -80)

                Circle()
                    .fill(Color.teal600.opacity(0.18))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -60, y: geo.size.height - 200)
            }
            .ignoresSafeArea()

            TabView(selection: $currentStep) {
                Screen1Hook(onNext: { go(to: 1) }, onSkip: { go(to: 5) })
                    .tag(0)
                Screen2HowItWorks(onNext: { go(to: 2) }, onSkip: { go(to: 5) })
                    .tag(1)
                Screen3PantryPreview(onNext: { go(to: 3) }, onSkip: { go(to: 5) })
                    .tag(2)
                Screen4Recipes(onNext: { go(to: 4) }, onSkip: { go(to: 5) })
                    .tag(3)
                Screen5Notifications(onNext: { go(to: 5) })
                    .tag(4)
                PaywallScreen(onComplete: { hasCompletedOnboarding = true })
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.35), value: currentStep)
        }
    }

    private func go(to step: Int) {
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep = step
        }
    }
}
