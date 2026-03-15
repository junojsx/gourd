//
//  gourdApp.swift
//  gourd
//

import SwiftUI

@main
struct gourdApp: App {
    @State private var authManager = AuthManager()
    @State private var pantryRepo  = PantryRepository()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(pantryRepo)
                // Kick off a fetch the moment auth is confirmed — before any tab renders.
                // Restarts whenever isAuthenticated flips (login / logout).
                .task(id: authManager.isAuthenticated) {
                    if authManager.isAuthenticated {
                        await pantryRepo.fetchItems()
                    } else {
                        pantryRepo.clearCache()
                    }
                }
        }
    }
}
