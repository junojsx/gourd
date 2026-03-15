//
//  ContentView.swift
//  gourd
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var auth

    var body: some View {
        switch auth.authState {
        case .loading:
            splashView
        case .unauthenticated:
            NavigationStack {
                SignInView()
            }
        case .authenticated(_):
            MainTabView()
        }
    }

    private var splashView: some View {
        ZStack {
            Color.ftWarmBeige.ignoresSafeArea()
            VStack(spacing: 24) {
                Image("GourdLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                ProgressView()
                    .tint(Color.ftOlive)
                    .scaleEffect(1.2)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
}
