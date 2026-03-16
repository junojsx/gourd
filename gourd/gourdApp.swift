//
//  gourdApp.swift
//  gourd
//

import SwiftUI

@main
struct gourdApp: App {
    @State private var authManager   = AuthManager()
    @State private var pantryRepo    = PantryRepository()
    @State private var recipeRepo    = RecipeRepository()
    @State private var showCookNow   = false
    @State private var cookNowFilter: CookNowFilter?

    private let scheduler = ExpiryNotificationScheduler.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(pantryRepo)
                .environment(recipeRepo)
                // Kick off a fetch the moment auth is confirmed — before any tab renders.
                // Restarts whenever isAuthenticated flips (login / logout).
                .task(id: authManager.isAuthenticated) {
                    if authManager.isAuthenticated {
                        await pantryRepo.fetchItems()
                        await recipeRepo.fetchAll()
                        // Request permission on first sign-in, then reschedule.
                        await scheduler.requestAuthorisation()
                        await scheduler.reschedule(items: pantryRepo.items)
                    } else {
                        pantryRepo.clearCache()
                        recipeRepo.clearCache()
                        // Clear notifications when signed out
                        await scheduler.reschedule(items: [])
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

    /// Handles `freshtrack://cook-now` and `freshtrack://cook-now?window=3day&ids=uuid1,uuid2`
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "freshtrack", url.host == "cook-now" else { return }
        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        cookNowFilter = CookNowFilter(from: params)
        showCookNow = true
    }
}
