//
//  FeedbackSheetView.swift
//  gourd
//

import SwiftUI

struct FeedbackSheetView: View {

    @Environment(\.dismiss) private var dismiss

    private let feedbackURL = URL(string: "https://gourdo-app.com/feedback")!

    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                FeedbackWebView(url: feedbackURL)
                    .ignoresSafeArea(edges: .bottom)

                if isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(Color.ftOlive)
                            .scaleEffect(1.2)
                            .padding(.top, 80)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.ftWarmBeige)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isLoading = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("Share Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.ftBody(15, weight: .semibold))
                        .foregroundStyle(Color.ftDeepForest)
                }
            }
        }
    }
}
