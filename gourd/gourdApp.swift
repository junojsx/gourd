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
        }
    }
}
