//
//  Screen1Hook.swift
//  gourdo
//
//  Onboarding Screen 1 — Brand intro + value hook.
//

import SwiftUI

struct Screen1Hook: View {
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 7, current: 0)
                .padding(.top, 20)
                .padding(.bottom, 32)

            // Wordmark hero
            VStack(spacing: 10) {
                Image("OnboardingLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .cornerRadius(32)

                Text("gourdo")
                    .font(.ftDisplay(42))
                    .foregroundColor(.textPrimary)

                Text("Know what's about to expire")
                    .font(.ftBody(14))
                    .foregroundColor(.textMuted)
            }
            .padding(.bottom, 32)

            // Stats row
            HStack(spacing: 10) {
                StatChip(number: "$1,500", label: "wasted per household per year")
                StatChip(number: "30%",    label: "of food bought never gets eaten")
            }
            .padding(.bottom, 28)

            // Headline
            (Text("Stop throwing ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("money")
                .font(.ftDisplay(28))
                .foregroundColor(.green100)
            + Text(" in the trash.")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)

            Text("Most families waste $125 a month on groceries that expire before they're touched. Gourdo changes that \u{2014} starting today.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            OnboardingPrimaryButton(title: "Let's fix that", action: onNext)
            SkipButton(action: onSkip)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
