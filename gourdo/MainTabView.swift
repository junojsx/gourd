//
//  MainTabView.swift
//  gourdo
//

import SwiftUI

// MARK: - Tab Bar Visibility Preference

struct HideTabBarKey: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func hideTabBar() -> some View {
        preference(key: HideTabBarKey.self, value: true)
    }
}

// MARK: - App Tabs

enum AppTab {
    case home, pantry, recipes, setup
}

// MARK: - MainTabView

struct MainTabView: View {
    @Environment(PantryRepository.self) private var repo
    @State private var selectedTab: AppTab = .home
    @State private var showQuickScan = false
    @State private var tabBarHidden = false

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
            .onPreferenceChange(HideTabBarKey.self) { tabBarHidden = $0 }

            if !tabBarHidden {
                tabBar
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showQuickScan) {
            ScanProductView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .environment(repo)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.ftWarmBeige)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.ftSoftClay.opacity(0.4))
                        .frame(height: 1)
                }
                .frame(height: 88)
                .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill",     label: "HOME",    tab: .home,    selectedTab: $selectedTab)
                TabBarButton(icon: "refrigerator",   label: "PANTRY",  tab: .pantry,  selectedTab: $selectedTab)

                // FAB center space
                Spacer().frame(width: 72)

                TabBarButton(icon: "book.fill",      label: "RECIPES", tab: .recipes, selectedTab: $selectedTab)
                TabBarButton(icon: "gearshape.fill", label: "SETUP",   tab: .setup,   selectedTab: $selectedTab)
            }
            .padding(.horizontal, 8)
            .padding(.top, 10)

            // FAB — Quick Scan
            Button(action: { showQuickScan = true }) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.ftWarmBeige)
                    .frame(width: 54, height: 54)
                    .background(Circle().fill(Color.ftPrimaryBg))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
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
