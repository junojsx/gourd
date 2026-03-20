//
//  ContentView.swift
//  gourd
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var auth
    @Environment(SubscriptionManager.self) private var subscriptions
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("hasSeenProWelcome") private var hasSeenProWelcome = false
    @State private var startWithSignUp = true

    var body: some View {
        if !hasSeenWelcome {
            // Step 1: Welcome
            WelcomeScreen(
                onGetStarted: {
                    startWithSignUp = true
                    hasSeenWelcome = true
                    // Clear any stale keychain session so the user always goes
                    // through sign-up after onboarding, not straight to the paywall.
                    Task { try? await auth.signOut() }
                },
                onSignIn: {
                    startWithSignUp = false
                    hasSeenWelcome = true
                    hasSeenOnboarding = true
                }
            )
        } else if !hasSeenOnboarding {
            // Step 2: Value screens (Hook → Sign-up pitch)
            OnboardingFlow(
                onComplete: { hasSeenOnboarding = true },
                onSignIn: { startWithSignUp = false; hasSeenOnboarding = true }
            )
        } else {
            switch auth.authState {
            case .loading:
                splashView
            case .unauthenticated:
                // Step 3: Sign Up / Sign In
                NavigationStack {
                    if startWithSignUp {
                        SignUpView()
                    } else {
                        SignInView()
                    }
                }
            case .authenticated(_):
                if subscriptions.isLoadingInitial {
                    // Brief pause while RevenueCat fetches CustomerInfo for the first time.
                    splashView
                } else if subscriptions.isProSubscriber {
                    if !hasSeenProWelcome {
                        // Step 5a: Just subscribed — show welcome screen once
                        SubscriptionSuccessScreen {
                            hasSeenProWelcome = true
                        }
                    } else {
                        // Step 5b: Returning subscriber — go straight to app
                        MainTabView()
                    }
                } else {
                    // Step 4: Not subscribed — hard paywall
                    PaywallScreen()
                }
            }
        }
    }

    private var splashView: some View {
        ZStack {
            Color.ftWarmBeige.ignoresSafeArea()
            VStack(spacing: 16) {
                Image("GourdLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                Text("gourdo")
                    .font(.ftDisplay(32))
                    .foregroundStyle(Color.ftDeepForest)
                ProgressView()
                    .tint(Color.ftOlive)
                    .scaleEffect(1.2)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
}
