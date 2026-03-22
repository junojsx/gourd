//
//  FeedbackWebView.swift
//  gourd
//
//  Simple UIViewRepresentable wrapping WKWebView for in-app browsing.
//

import SwiftUI
import WebKit

struct FeedbackWebView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = UIColor(Color.ftWarmBeige)
        webView.isOpaque = false
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
