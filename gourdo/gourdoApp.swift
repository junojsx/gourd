//
//  gourdoApp.swift
//  gourdo
//

import PostHog
import RevenueCat
import Supabase
import SwiftUI

@main
struct gourdoApp: App {
    @State private var authManager         = AuthManager()
    @State private var subscriptionManager = SubscriptionManager()
    @State private var pantryRepo          = PantryRepository()
    @State private var recipeRepo          = RecipeRepository()
    @State private var themeManager        = ThemeManager()
    @State private var showCookNow         = false
    @State private var cookNowFilter: CookNowFilter?

    private let scheduler = ExpiryNotificationScheduler.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(subscriptionManager)
                .environment(pantryRepo)
                .environment(recipeRepo)
                .environment(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                // Configure RevenueCat once the app scene is ready,
                // then start listening for subscription changes.
                .task {
                    BarcodeCache.evictExpired()

                    // PostHog — analytics
                    let phConfig = PostHogConfig(
                        apiKey: Secrets.postHogAPIKey,
                        host: "https://us.i.posthog.com"
                    )
                    phConfig.captureApplicationLifecycleEvents = true
                    #if DEBUG
                    phConfig.optOut = true   // keep dev events out of production data
                    #endif
                    PostHogSDK.shared.setup(phConfig)

                    // RevenueCat
                    #if DEBUG
                    Purchases.logLevel = .debug
                    #endif
                    Purchases.configure(withAPIKey: Secrets.revenueCatAPIKey)
                    subscriptionManager.prefetchOfferings()
                    await subscriptionManager.startListening()
                }
                // Sync RevenueCat user identity whenever Supabase auth changes.
                .task(id: authManager.isAuthenticated) {
                    if authManager.isAuthenticated {
                        // Link RC anonymous user to the Supabase user ID so purchase
                        // history is always tied to the correct account.
                        if let userId = authManager.currentSession?.user.id.uuidString {
                            await subscriptionManager.logIn(userId: userId)
                            // Identify the user in PostHog and attach super-properties
                            PostHogSDK.shared.identify(
                                userId,
                                userProperties: [
                                    "email": authManager.currentSession?.user.email ?? "",
                                    "tier": subscriptionManager.isProSubscriber ? "pro" : "free"
                                ]
                            )
                            PostHogSDK.shared.register([
                                "platform": "ios",
                                "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
                            ])
                        }
                        await pantryRepo.fetchItems()
                        await recipeRepo.fetchAll()
                        await scheduler.reschedule(items: pantryRepo.items)
                    } else {
                        await subscriptionManager.logOut()
                        pantryRepo.clearCache()
                        recipeRepo.clearCache()
                        await scheduler.reschedule(items: [])
                        PostHogSDK.shared.reset()
                    }
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .sheet(isPresented: $showCookNow) {
                    NavigationStack {
                        CookNowView(filter: cookNowFilter)
                            .environment(pantryRepo)
                            .environment(recipeRepo)
                    }
                }
        }
    }

    // MARK: - Deep Link Handler

    /// Handles `gourdo://cook-now` and `gourdo://cook-now?window=3day&ids=uuid1,uuid2`
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "gourdo", url.host == "cook-now" else { return }
        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        cookNowFilter = CookNowFilter(from: params)
        showCookNow = true
        AnalyticsService.notificationTapped(type: "cook_now")
    }
}
