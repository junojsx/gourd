//
//  MainTabView.swift
//  gourd
//

import SwiftUI

// MARK: - App Tabs

enum AppTab {
    case home, pantry, recipes, setup
}

// MARK: - MainTabView

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:   HomeView()
                case .pantry: NavigationStack { PantryView() }
                case .recipes:  RecipesTabView()
                case .setup:  SetupView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ZStack(alignment: .top) {
            // Background
            Color.white
                .shadow(color: Color.ftDeepForest.opacity(0.1), radius: 16, x: 0, y: -4)
                .frame(height: 88)
                .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill",       label: "HOME",   tab: .home,   selectedTab: $selectedTab)
                TabBarButton(icon: "refrigerator",     label: "PANTRY", tab: .pantry, selectedTab: $selectedTab)

                // FAB center space
                Spacer().frame(width: 72)

                TabBarButton(icon: "book.fill",      label: "RECIPES",  tab: .recipes,  selectedTab: $selectedTab)
                TabBarButton(icon: "gearshape.fill",   label: "SETUP",  tab: .setup,  selectedTab: $selectedTab)
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)

            // FAB
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(Color.ftDeepForest))
                    .ftShadowMd()
            }
            .offset(y: -22)
        }
        .frame(height: 88)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let label: String
    let tab: AppTab
    @Binding var selectedTab: AppTab

    private var isSelected: Bool { selectedTab == tab }

    var body: some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.ftBody(9, weight: .semibold))
                    .kerning(0.8)
            }
            .foregroundStyle(isSelected ? Color.ftOlive : Color.ftDeepForest.opacity(0.3))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Placeholder

struct PlaceholderView: View {
    let title: String
    var body: some View {
        ZStack {
            Color.ftWarmBeige.ignoresSafeArea()
            Text(title)
                .font(.ftDisplay(28, weight: .bold))
                .foregroundStyle(Color.ftDeepForest)
        }
    }
}

#Preview {
    MainTabView()
}
