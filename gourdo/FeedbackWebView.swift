//
//  FeedbackWebView.swift
//  gourdo
//
//  UIViewControllerRepresentable wrapping SFSafariViewController for
//  reliable in-app browsing — handles redirects, cookies, and modern
//  web features the same way Safari does.
//

import SafariServices
import SwiftUI

struct FeedbackWebView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        if #unavailable(iOS 26.0) {
            vc.preferredControlTintColor = UIColor(Color.ftOlive)
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
