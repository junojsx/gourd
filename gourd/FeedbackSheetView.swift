//
//  FeedbackSheetView.swift
//  gourd
//

import SwiftUI

struct FeedbackSheetView: View {

    private let feedbackURL = URL(string: "https://gourdo-app.com/feedback")!

    var body: some View {
        FeedbackWebView(url: feedbackURL)
            .ignoresSafeArea()
    }
}
