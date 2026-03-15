//
//  gourdApp.swift
//  gourd
//

import SwiftUI

@main
struct gourdApp: App {
    @State private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
        }
    }
}
