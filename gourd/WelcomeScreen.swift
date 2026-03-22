//
//  WelcomeScreen.swift
//  gourd
//
//  First screen users see. Leads to onboarding or sign-in.
//

import SwiftUI

struct WelcomeScreen: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    var body: some View {
        ZStack {
            Color.surfaceBase.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + wordmark + tagline
                VStack(spacing: 14) {
                    Image("OnboardingLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .cornerRadius(28)

                    // "gour" white + "do" green
                    HStack(spacing: 0) {
                        Text("gour")
                            .foregroundColor(.textPrimary)
                        Text("do")
                            .foregroundColor(.green200)
                    }
                    .font(.ftDisplay(42))

                    Text("Stop throwing food away. Know\nwhat to eat before it\u{2019}s too late.")
                        .font(.ftBody(15))
                        .foregroundColor(.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                Spacer()

                // CTAs
                VStack(spacing: 10) {
                    Button(action: onGetStarted) {
                        Text("Get started")
                            .font(.ftBody(16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .cornerRadius(14)
                    }

                    Button(action: onSignIn) {
                        Text("I already have an account")
                            .font(.ftBody(15))
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}
