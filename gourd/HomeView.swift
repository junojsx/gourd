//
//  HomeView.swift
//  gourd
//

import SwiftUI

struct HomeView: View {
    @Environment(PantryRepository.self) private var repo

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroTextSection
                        .padding(.top, 20)

                    pantryStatsCard
                        .padding(.top, 20)

                    Rectangle()
                        .fill(Color.ftSoftClay.opacity(0.6))
                        .frame(height: 1)
                        .padding(.top, 32)

                    coreExperienceSection
                        .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
        .background(Color.ftWarmBeige.ignoresSafeArea())
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text("Gourdo")
                    .font(.ftBody(17, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "person.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.ftDeepForest)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.ftWarmBeige)
    }

    // MARK: - Hero Text

    private var heroTextSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Elegant Kitchen")
                .font(.ftDisplay(36))
                .foregroundStyle(Color.ftDeepForest)
            Text("Management.")
                .font(.ftDisplay(36))
                .foregroundStyle(Color.ftDeepForest)

            Text("Master your inventory with intuitive barcode scanning and smart expiry alerts. Minimize waste, maximize freshness.")
                .font(.ftBody(15))
                .foregroundStyle(Color.ftDeepForest50)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
        }
    }

    // MARK: - Pantry Stats Card

    private var totalItems:    Int { repo.items.count }
    private var expiringItems: Int { repo.items.filter { [.useSoon, .urgent].contains($0.freshnessGrade) }.count }
    private var expiredItems:  Int { repo.items.filter { $0.freshnessGrade == .expired }.count }

    private var pantryStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Pantry Overview")
                    .font(.ftBody(13, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.45))
                    .kerning(0.5)
                Spacer()
                Image(systemName: "refrigerator")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.3))
            }

            HStack(spacing: 0) {
                statCell(
                    value: totalItems,
                    label: "Total Items",
                    icon: "archivebox.fill",
                    valueColor: Color.ftDeepForest,
                    tint: Color.ftOlive.opacity(0.1)
                )

                statDivider

                statCell(
                    value: expiringItems,
                    label: "Expiring Soon",
                    icon: "clock.badge.exclamationmark.fill",
                    valueColor: Color.ftBronze,
                    tint: Color.ftBronze.opacity(0.08)
                )

                statDivider

                statCell(
                    value: expiredItems,
                    label: "Expired",
                    icon: "exclamationmark.triangle.fill",
                    valueColor: Color.ftCrimson,
                    tint: Color.ftCrimson.opacity(0.08)
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.ftCardBg.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.ftSoftClay.opacity(0.5), lineWidth: 1)
                )
        )
        .ftShadowSm()
    }

    private func statCell(value: Int, label: String, icon: String, valueColor: Color, tint: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(valueColor)
            }
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(valueColor)
            Text(label)
                .font(.ftBody(11))
                .foregroundStyle(Color.ftDeepForest.opacity(0.45))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.ftSoftClay.opacity(0.6))
            .frame(width: 1, height: 70)
    }

    // MARK: - Core Experience

    private var coreExperienceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CORE EXPERIENCE")
                .font(.ftBody(11, weight: .semibold))
                .foregroundStyle(Color.ftDeepForest.opacity(0.4))
                .kerning(1.5)

            FeatureCard(
                icon: "barcode.viewfinder",
                title: "Precision Scan",
                description: "Instant product recognition for seamless inventory entry."
            )
            FeatureCard(
                icon: "bell.badge.fill",
                title: "Smart Tracking",
                description: "Intelligent expiry alerts before your food goes to waste."
            )
            FeatureCard(
                icon: "leaf.fill",
                title: "Zero Waste",
                description: "Eco-conscious kitchen management to reduce your footprint."
            )
        }
    }
}

// MARK: - Feature Card

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.ftWarmBeige)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.ftSoftClay, lineWidth: 1)
                    )
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.ftDeepForest.opacity(0.55))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.ftBody(15, weight: .semibold))
                    .foregroundStyle(Color.ftDeepForest)
                Text(description)
                    .font(.ftBody(13))
                    .foregroundStyle(Color.ftDeepForest50)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.ftCardBg.opacity(0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.ftSoftClay.opacity(0.45), lineWidth: 1)
                )
        )
        .ftShadowSm()
    }
}

#Preview {
    HomeView()
        .environment(PantryRepository())
}
