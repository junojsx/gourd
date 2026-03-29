//
//  OnboardingFlow.swift
//  gourdo
//
//  7-screen value flow ending with a sign-up pitch.
//  onComplete → user wants to create an account (shows SignUpView)
//  onSignIn   → user already has an account (shows SignInView)
//

import SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void
    let onSignIn: () -> Void

    @State private var currentStep: Int = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

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
                Screen1Hook(onNext: { go(to: 1) }, onSkip: { go(to: 9) })
                    .tag(0)
                Screen2HowItWorks(onNext: { go(to: 2) }, onSkip: { go(to: 9) })
                    .tag(1)
                Screen3PantryPreview(onNext: { go(to: 3) }, onSkip: { go(to: 9) })
                    .tag(2)
                Screen4Recipes(onNext: { go(to: 4) }, onSkip: { go(to: 9) })
                    .tag(3)
                Screen5Notifications(onNext: { go(to: 5) })
                    .tag(4)
                Screen6NotificationsPermission(onNext: { go(to: 6) })
                    .tag(5)
                ScreenScanGuide(onNext: { go(to: 7) })
                    .tag(6)
                ScreenExpiryGuide(onNext: { go(to: 8) })
                    .tag(7)
                ScreenRecipeGuide(onNext: { go(to: 9) })
                    .tag(8)
                Screen7SignUpCTA(onCreateAccount: onComplete, onSignIn: onSignIn)
                    .tag(9)
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
