//
//  Screen5Notifications.swift
//  gourd
//
//  Onboarding Screen 5 — Notifications: "We'll remind you before it's too late."
//

import SwiftUI

struct Screen5Notifications: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProgressDots(total: 5, current: 4)
                .padding(.top, 20)
                .padding(.bottom, 20)

            // Mock iOS notification banner
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green800)
                    .frame(width: 36, height: 36)
                    .overlay(Text("\u{1F96C}").font(.system(size: 18)))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Gourdo")
                        .font(.ftBody(12, weight: .semibold))
                        .foregroundColor(.textPrimary.opacity(0.9))
                    (Text("Your spinach expires ")
                        .font(.ftBody(11))
                        .foregroundColor(.textMuted)
                    + Text("today")
                        .font(.ftBody(11, weight: .semibold))
                        .foregroundColor(.textPrimary.opacity(0.7))
                    + Text(". We've got a great recipe ready \u{2014} takes 20 min.")
                        .font(.ftBody(11))
                        .foregroundColor(.textMuted))
                    Text("now")
                        .font(.ftBody(10))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.top, 2)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.14), lineWidth: 0.5))
            .cornerRadius(14)
            .padding(.bottom, 24)

            (Text("We'll remind you before it's ")
                .font(.ftDisplay(28))
                .foregroundColor(.textPrimary)
            + Text("too late.")
                .font(.ftDisplay(28))
                .foregroundColor(.green100))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)

            Text("Timely nudges at the right moment \u{2014} so groceries get used, not binned. Set your preferred alert time and we handle the rest.")
                .font(.ftBody(14))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            OnboardingPrimaryButton(title: "See Gourdo Pro \u{2192}", action: onNext)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
    }
}
